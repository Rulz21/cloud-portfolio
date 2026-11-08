# Cloud Portfolio

My personal portfolio website, hosted on AWS and built the way a real cloud team would.

**Stack (planned):** AWS (S3, CloudFront, Route 53, Lambda, DynamoDB), Terraform, GitHub Actions

## Build Log

### Session 1: Account setup
- **Did:** Created AWS account, turned on MFA with an authenticator app, set a $5 monthly budget alert.
- **Confused by:** My account uses AWS's new "projects" experience, so there was no root user or Security credentials menu. Found MFA under AWS Settings → Manage security and sign-in.
- **Learned:** MFA protects against stolen passwords. Budgets warn you; spend limits stop spending.

### Session 2: First homepage + Git setup
- **Did:** Installed Git and VS Code, cloned the repo, created site/index.html, and pushed it to GitHub.
- **Confused by:** "git is not recognized" error (terminal needed restarting after installing Git); a typo in `user.name`; cloning with a file link instead of the repo link.
- **Learned:** Repo links end in `.git`. Workflow: clone once, then add → commit → push.

### Session 3: Create the cloudfront
- **Did:** Set up the cloudfront and configure the distribution's settings.
- **Confused by:** the choice of the origin type (need to make sure my website use the correct origin)
- **Learned:** Origin type is just different kind of storerooms. Security should match the risk. My site didnt need one yet.

### Session 4: Infrastructure as Code

- **Did:** Rebuilt the site with Terraform (S3 + OAC + CloudFront + bucket policy), uploaded with aws s3 sync, deleted the hand-made version.
- **Confused by:** network timeouts downloading the provider; “undeclared resource” and “requires explicit configuration” errors (both caused by unsaved files).
- **Learned:** Terraform describes the end result and works out the order from references. State = Terraform’s memory; never edit Terraform-managed resources by hand (drift).

### Session 5 Store Terraform transfer state in S3 bucket and create github robot 

- **Did:** Store terraform transfer state with locking in s3 bucket. Try to make an oidc pass for my github robot
- **Confused:** SCP cause my github robot cant create an oidc pass and accessing aws
- **Learned:** SCP is a safe policy. I need to upgrade my aws account to make the oidc pass. I use a least previliege key instead (IAM user - only for my github robot)