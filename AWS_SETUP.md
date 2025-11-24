# AWS S3 Auto-Sync Setup

This repository automatically syncs data from S3 buckets on environment startup.

## Configuration Options

### Option 1: IAM Role Assumption (Recommended)

Use IAM roles for secure, temporary credentials without storing secrets.

#### Step 1: Create IAM Role

1. Go to AWS Console → IAM → Roles → Create Role
2. Select "Custom trust policy"
3. Use this trust policy (replace with your AWS account ID):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR_ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
```

4. Attach permissions policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:ListAllMyBuckets"
      ],
      "Resource": [
        "arn:aws:s3:::*",
        "arn:aws:s3:::*/*"
      ]
    }
  ]
}
```

5. Name the role (e.g., `GitpodS3ReadRole`)
6. Copy the Role ARN (e.g., `arn:aws:iam::841512165447:role/GitpodS3ReadRole`)

#### Step 2: Configure Gitpod Environment Variables

Add the role ARN as an environment variable in your Gitpod workspace:

**Via Gitpod Dashboard:**
1. Go to [gitpod.io/variables](https://gitpod.io/variables)
2. Add new variable:
   - Name: `ONAS3SYNCDEMO_ROLE_ARN`
   - Value: `arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME`
   - Scope: Select your repository

**Via devcontainer.json:**

Uncomment and update in `.devcontainer/devcontainer.json`:

```json
"containerEnv": {
    "ONAS3SYNCDEMO_ROLE_ARN": "arn:aws:iam::841512165447:role/GitpodS3ReadRole"
}
```

#### Step 3: Provide Base Credentials

The role assumption requires initial AWS credentials. Set these in Gitpod:

1. Go to [gitpod.io/variables](https://gitpod.io/variables)
2. Add these variables:
   - `ONAS3SYNCDEMO_ACCESS_KEY_ID`: Your IAM user access key
   - `ONAS3SYNCDEMO_SECRET_ACCESS_KEY`: Your IAM user secret key
   - Scope: Select your repository

The IAM user only needs `sts:AssumeRole` permission:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:role/GitpodS3ReadRole"
    }
  ]
}
```

---

### Option 2: Direct Credentials (Without Role Assumption)

Use IAM user credentials directly without role assumption.

#### Configure in Gitpod

Add these environment variables in [gitpod.io/variables](https://gitpod.io/variables):

- `ONAS3SYNCDEMO_ACCESS_KEY_ID`
- `ONAS3SYNCDEMO_SECRET_ACCESS_KEY`

Or uncomment in `.devcontainer/devcontainer.json`:

```json
"containerEnv": {
    "ONAS3SYNCDEMO_ACCESS_KEY_ID": "AKIA...",
    "ONAS3SYNCDEMO_SECRET_ACCESS_KEY": "..."
}
```

⚠️ **Note:** The IAM user must have S3 permissions directly attached.

---

## How It Works

1. On environment startup, `.devcontainer/startup-s3-sync.sh` runs automatically
2. Maps `ONAS3SYNCDEMO_*` environment variables to standard AWS credentials
3. If `ONAS3SYNCDEMO_ROLE_ARN` is set, it assumes the role to get temporary credentials
4. Otherwise, it uses the provided AWS credentials
5. Syncs all accessible S3 buckets to `s3_extracted_data/`
6. Only downloads new or changed files (incremental sync)

## Manual Sync

To manually trigger a sync:

```bash
./.devcontainer/startup-s3-sync.sh
```

## Troubleshooting

### "AWS credentials not configured or invalid"

- Verify environment variables are set in Gitpod
- Check IAM user credentials are valid
- If using role assumption, ensure base credentials have `sts:AssumeRole` permission
- Check IAM role trust policy allows your account

### "Failed to assume role"

- Verify the role ARN is correct
- Check the trust policy includes your AWS account
- Ensure base credentials are valid

### "Access Denied" on specific buckets

- Update the role's S3 permissions policy
- Some buckets may have additional bucket policies blocking access

## Security Best Practices

1. ✅ Use IAM roles with temporary credentials
2. ✅ Apply least-privilege permissions (only required S3 buckets)
3. ✅ Store credentials in Gitpod environment variables, not in code
4. ✅ Rotate IAM user credentials regularly
5. ❌ Never commit credentials to git
