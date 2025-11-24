# S3 Data Sync

Automatic S3 data synchronization with IAM role assumption for Gitpod environments.

## Features

- 🔄 Automatic S3 bucket sync on environment startup
- 🔐 IAM role assumption for secure credential management
- 📦 Incremental sync (only downloads new/changed files)
- ✅ Support for 80+ S3 buckets
- 🚀 Zero-configuration after initial setup

## Quick Start

1. **Set up IAM role** (see [AWS_SETUP.md](AWS_SETUP.md) for detailed instructions)
   - Create role with S3 full access
   - Configure trust policy
   - Copy the role ARN

2. **Configure Gitpod environment variables** at [gitpod.io/variables](https://gitpod.io/variables):
   - `ONAS3SYNCDEMO_ROLE_ARN`: Your IAM role ARN
   - `ONAS3SYNCDEMO_ACCESS_KEY_ID`: Base credentials
   - `ONAS3SYNCDEMO_SECRET_ACCESS_KEY`: Base credentials
   - `ONAS3SYNCDEMO_SESSION_TOKEN`: Session token (if using temporary credentials)

3. **Start environment** - S3 data syncs automatically to `s3_extracted_data/`

## Manual Sync

Run the sync script manually:

```bash
./.devcontainer/startup-s3-sync.sh
```

Or use the standalone extraction script:

```bash
./extract_s3_data.sh
```

## Configuration

Edit `.devcontainer/devcontainer.json` to customize:
- Change output directory
- Modify sync behavior
- Add additional startup commands

## Documentation

- [AWS_SETUP.md](AWS_SETUP.md) - Complete IAM role setup guide
- [.devcontainer/startup-s3-sync.sh](.devcontainer/startup-s3-sync.sh) - Startup script
- [extract_s3_data.sh](extract_s3_data.sh) - Manual extraction script

## Current Configuration

- **Role ARN Variable**: `ONAS3SYNCDEMO_ROLE_ARN` (set to `arn:aws:iam::841512165447:role/S3AccessDemo`)
- **Output Directory**: `s3_extracted_data/`
- **Sync Method**: Incremental (aws s3 sync)
- **Credential Variables**: `ONAS3SYNCDEMO_*` prefix for project-specific isolation

## Security

- Credentials stored in Gitpod environment variables (not in code)
- IAM role assumption for temporary credentials
- S3 full access permissions (read/write)

## Repository

Created in: [ona-SE/s3-data-sync](https://github.com/ona-SE/s3-data-sync)
