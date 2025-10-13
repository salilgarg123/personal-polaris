# Bastion Host Configuration
# This file contains the bastion host for secure access to VPC resources

# No external IP - bastion will be accessible only via IAP tunnel

# Service account for the bastion host
resource "google_service_account" "bastion" {
  count = var.bastion_enabled ? 1 : 0
  
  account_id   = "sa-bastion-${var.environment}"
  display_name = "Bastion Host Service Account - ${title(var.environment)}"
  description  = "Service account for the bastion host in ${var.environment} environment"
  project      = var.project_id
}

# IAM roles for the bastion host service account
resource "google_project_iam_member" "bastion_os_login" {
  count = var.bastion_enabled ? 1 : 0
  
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "serviceAccount:${google_service_account.bastion[0].email}"
}

resource "google_project_iam_member" "bastion_cloud_sql_proxy" {
  count = var.bastion_enabled ? 1 : 0
  
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.bastion[0].email}"
}

# IAP tunnel access permissions for users
resource "google_project_iam_member" "bastion_iap_tunnel_user" {
  for_each = var.bastion_enabled ? toset(var.iap_users) : []
  
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = each.value
}

# IAP tunnel instance access permissions
resource "google_compute_instance_iam_member" "bastion_iap_tunnel_instance" {
  for_each = var.bastion_enabled ? toset(var.iap_users) : []
  
  project       = var.project_id
  zone          = var.default_zone
  instance_name = google_compute_instance.bastion[0].name
  role          = "roles/compute.osLogin"
  member        = each.value
}

# Bastion host compute instance
resource "google_compute_instance" "bastion" {
  count = var.bastion_enabled ? 1 : 0
  
  name         = "gce-bastion-${var.environment}"
  machine_type = var.bastion_machine_type
  zone         = var.default_zone
  project      = var.project_id

  # Enable OS Login for better security
  metadata = {
    enable-oslogin = "TRUE"
    ssh-keys = length(var.bastion_ssh_keys) > 0 ? join("\n", [
      for key in var.bastion_ssh_keys : "ubuntu:${key}"
    ]) : ""
  }

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.bastion_disk_size
      type  = var.bastion_disk_type
    }
  }

  # Network configuration - no external IP, access via IAP tunnel only
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    # No access_config block = no external IP
  }

  # Service account
  service_account {
    email  = google_service_account.bastion[0].email
    scopes = ["cloud-platform"]
  }

  # Startup script to install necessary tools
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e  # Exit on any error
    
    # Update package list
    apt-get update
    
    # Install basic packages
    apt-get install -y \
      curl \
      wget \
      git \
      unzip \
      postgresql-client \
      postgresql-client-common \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release
    
    # Add Google Cloud SDK repository
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    
    # Update package list with new repository
    apt-get update
    
    # Install Google Cloud CLI
    apt-get install -y google-cloud-cli
    
    # Install Cloud SQL Proxy
    curl -o /usr/local/bin/cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
    chmod +x /usr/local/bin/cloud-sql-proxy
    
    # Configure Cloud SQL proxy for database access
    mkdir -p /opt/cloud-sql-proxy
    chown ubuntu:ubuntu /opt/cloud-sql-proxy
    
    # Create a systemd service for Cloud SQL proxy
    cat > /etc/systemd/system/cloud-sql-proxy.service << 'SYSTEMD_EOF'
[Unit]
Description=Google Cloud SQL Proxy
After=network-online.target
Wants=network-online.target
Requires=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/cloud-sql-proxy
ExecStart=/usr/local/bin/cloud-sql-proxy --port=5432 --private-ip ${google_sql_database_instance.postgres_instance.connection_name}
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SYSTEMD_EOF

    # Set proper permissions
    chown -R ubuntu:ubuntu /opt/cloud-sql-proxy
    
    # Reload systemd and enable service
    systemctl daemon-reload
    systemctl enable cloud-sql-proxy
    
    # Wait for metadata server to be available and network to be ready
    echo "Waiting for metadata server..." >> /var/log/startup.log
    while ! curl -s -f -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token > /dev/null; do
        sleep 2
        echo "Waiting for service account credentials..." >> /var/log/startup.log
    done
    
    # Wait a bit more for network stability
    sleep 5
    
    # Test Cloud SQL Proxy connection
    echo "Testing Cloud SQL Proxy connection..." >> /var/log/startup.log
    echo "Connection name: ${google_sql_database_instance.postgres_instance.connection_name}" >> /var/log/startup.log
    /usr/local/bin/cloud-sql-proxy --version >> /var/log/startup.log 2>&1
    
    # Start the systemd service
    systemctl start cloud-sql-proxy
    
    # Verify service started successfully
    sleep 3
    if systemctl is-active --quiet cloud-sql-proxy; then
        echo "Cloud SQL Proxy service started successfully" >> /var/log/startup.log
    else
        echo "WARNING: Cloud SQL Proxy service failed to start" >> /var/log/startup.log
        systemctl status cloud-sql-proxy >> /var/log/startup.log 2>&1 || true
    fi
    
    # Verify installations
    echo "Verifying installations..." >> /var/log/startup.log
    gcloud version >> /var/log/startup.log 2>&1
    /usr/local/bin/cloud-sql-proxy --version >> /var/log/startup.log 2>&1
    psql --version >> /var/log/startup.log 2>&1
    
    echo "Bastion host setup completed successfully" >> /var/log/startup.log
    echo "$(date): Setup completed" >> /var/log/startup.log
  EOF

  # Network tags for firewall rules
  tags = ["bastion-${var.environment}"]

  # Labels
  labels = merge(local.common_labels, {
    role = "bastion"
    type = "compute-instance"
  })

  # Security: Enable Shielded VM features
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Attach resource policy for scheduling (if enabled)
  resource_policies = var.bastion_schedule_enabled ? [
    google_compute_resource_policy.bastion_schedule[0].self_link
  ] : []

  depends_on = [
    google_project_service.required_apis["compute.googleapis.com"],
    google_compute_subnetwork.subnet
  ]
}

# Resource Schedule to stop bastion host daily
resource "google_compute_resource_policy" "bastion_schedule" {
  count = var.bastion_enabled && var.bastion_schedule_enabled ? 1 : 0
  
  name    = "bastion-${var.environment}-schedule"
  region  = var.default_region
  project = var.project_id

  description = "Schedule to automatically stop bastion host daily"

  instance_schedule_policy {
    vm_stop_schedule {
      schedule = var.bastion_stop_schedule
    }
    time_zone = var.bastion_schedule_timezone
  }

  depends_on = [
    google_project_service.required_apis["compute.googleapis.com"]
  ]
}

# Resource policy is attached directly to the instance via the resource_policies attribute

