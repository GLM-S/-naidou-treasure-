## Description: <br>
Tencent COS helps agents manage Tencent Cloud COS object storage, CI data intelligence processing, MetaInsight retrieval, and knowledge-base workflows through Node.js commands. <br>

This skill is ready for commercial/non-commercial use. <br>

## Publisher: <br>
[shawnminh](https://clawhub.ai/user/shawnminh) <br>

### License/Terms of Use: <br>
MIT-0 <br>


## Use Case: <br>
Developers and cloud operators use this skill to let an agent upload, download, list, process, and search objects in Tencent Cloud COS and CI-backed services. It is also used to create and query COS-backed knowledge bases when the user provides Tencent Cloud credentials and bucket configuration. <br>

### Deployment Geography for Use: <br>
Global <br>

## Known Risks and Mitigations: <br>
Risk: The skill can give an agent broad authority over Tencent Cloud COS and CI resources. <br>
Mitigation: Install only for intended COS/CI use, use STS or a tightly scoped sub-account limited to the target bucket, and avoid root or broad permanent keys. <br>
Risk: Sensitive Tencent Cloud credentials are required. <br>
Mitigation: Prefer ephemeral environment variables with STS credentials, avoid persistent .env storage when possible, and never echo credentials back to the user. <br>
Risk: Object deletion, bulk deletion, ACL/CORS changes, signed URL sharing, knowledge-base uploads, and generic ci-request calls can change resources or expose data. <br>
Mitigation: Require explicit user confirmation before these operations and review the target bucket, object keys, URL expiration, ACL/CORS settings, upload scope, and CI request body before execution. <br>


## Reference(s): <br>
- [ClawHub Tencent COS Skill](https://clawhub.ai/shawnminh/tencent-cos-skill) <br>
- [COS Node.js SDK Operation Reference](references/api_reference.md) <br>
- [Tencent Cloud COS Node.js SDK](https://cloud.tencent.com/document/product/436/8629) <br>
- [Tencent Cloud Data Intelligence](https://cloud.tencent.com/document/product/460) <br>
- [cos-nodejs-sdk-v5](https://github.com/tencentyun/cos-nodejs-sdk-v5) <br>


## Skill Output: <br>
**Output Type(s):** [text, markdown, code, shell commands, configuration, guidance] <br>
**Output Format:** [Markdown guidance with shell commands and JSON command outputs from the Tencent COS helper script.] <br>
**Output Parameters:** [1D] <br>
**Other Properties Related to Output:** [Requires Tencent Cloud SecretId, SecretKey, Region, and Bucket configuration; optional STS Token and dataset/domain settings are supported.] <br>

## Skill Version(s): <br>
1.1.7 (source: server-resolved release metadata) <br>

## Ethical Considerations: <br>
Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment. <br>
