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
   - `ONAS3SYNCDEMO_ACCESS_KEY_ID`: Your IAM user access key
   - `ONAS3SYNCDEMO_SECRET_ACCESS_KEY`: Your IAM user secret key

3. **Start environment** - S3 data syncs automatically to `s3_extracted_data/`

## Manual Sync

Run the sync script manually:

```bash
./.devcontainer/startup-s3-sync.sh
```

## AWS CLI Commands

Explore S3 buckets directly using AWS CLI:

```bash
# List all buckets
aws s3 ls

# List contents of a specific bucket
aws s3 ls s3://bucket-name/

# List contents recursively (all files)
aws s3 ls s3://bucket-name/ --recursive

# List with human-readable sizes
aws s3 ls s3://bucket-name/ --recursive --human-readable --summarize

# Download a specific file
aws s3 cp s3://bucket-name/path/to/file.txt ./

# View file contents without downloading
aws s3 cp s3://bucket-name/path/to/file.txt -

# Search for files by pattern
aws s3 ls s3://bucket-name/ --recursive | grep "pattern"

# Get bucket size and file count
aws s3 ls s3://bucket-name/ --recursive --summarize | tail -2
```

**Example workflow:**

```bash
# 1. List all buckets
aws s3 ls

# 2. Pick a bucket and explore its contents
aws s3 ls s3://blog-post-test-fernando/ --recursive

# 3. View a file
aws s3 cp s3://blog-post-test-fernando/my-shared-dir/testing-file.txt -
```

## Configuration

Edit `.devcontainer/devcontainer.json` to customize:
- Change output directory
- Modify sync behavior
- Add additional startup commands

## Documentation

- [AWS_SETUP.md](AWS_SETUP.md) - Complete IAM role setup guide
- [.devcontainer/startup-s3-sync.sh](.devcontainer/startup-s3-sync.sh) - Sync script

## Current Configuration

- **Role ARN Variable**: `ONAS3SYNCDEMO_ROLE_ARN` (set to `arn:aws:iam::841512165447:role/S3AccessDemo`)
- **Output Directory**: `s3_extracted_data/`
- **Sync Method**: Incremental (aws s3 sync)
- **Credential Variables**: `ONAS3SYNCDEMO_*` prefix for project-specific isolation

## Security

- Credentials stored in Gitpod environment variables (not in code)
- IAM role assumption provides temporary credentials with limited scope
- IAM user credentials only need `sts:AssumeRole` permission
- S3 full access granted through assumed role (not IAM user)

## Repository

Created in: [ona-SE/s3-data-sync](https://github.com/ona-SE/s3-data-sync)
