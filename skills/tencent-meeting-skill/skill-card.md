## Description: <br>
腾讯会议 helps agents schedule, update, cancel, and inspect Tencent Meeting sessions, participants, recordings, transcripts, and AI minutes for an authenticated Tencent Meeting account. <br>

This skill is ready for commercial/non-commercial use. <br>

## Publisher: <br>
[wemeeting](https://clawhub.ai/user/wemeeting) <br>

### License/Terms of Use: <br>
MIT-0 <br>


## Use Case: <br>
External users and teams with a Tencent Meeting token use this skill to manage meetings and retrieve meeting-related content from their Tencent Meeting account. It is intended for Tencent Meeting workflows such as scheduling, updating or canceling meetings, checking participants, listing recordings, searching transcripts, and retrieving AI minutes. <br>

### Deployment Geography for Use: <br>
Global <br>

## Known Risks and Mitigations: <br>
Risk: The skill can use the configured Tencent Meeting token to manage meetings and retrieve confidential meeting material such as attendees, recordings, download links, transcripts, and AI minutes. <br>
Mitigation: Install it only for trusted Tencent Meeting accounts and endpoints, keep TENCENT_MEETING_TOKEN scoped and protected, and review retrieved meeting content before sharing it. <br>
Risk: Meeting updates and cancellations can affect live business workflows. <br>
Mitigation: Confirm the meeting details with the user before modifying or canceling a meeting. <br>
Risk: Tool responses may include trace identifiers and basic client environment metadata. <br>
Mitigation: Display trace identifiers for support when needed, but avoid publishing them or meeting download links outside the intended support or meeting audience. <br>


## Reference(s): <br>
- [腾讯会议 MCP Tool Examples](references/api_references.md) <br>
- [腾讯会议 Error Dictionary](references/error_dictionary.md) <br>
- [腾讯会议 Version Management](references/version_management.md) <br>
- [Tencent Meeting](https://meeting.tencent.com/) <br>
- [Tencent Meeting token setup](https://meeting.tencent.com/ai-skill) <br>
- [Tencent Meeting MCP endpoint](https://mcp.meeting.tencent.com/mcp/wemeet-open/v1) <br>
- [ClawHub skill listing](https://clawhub.ai/wemeeting/tencent-meeting-skill) <br>


## Skill Output: <br>
**Output Type(s):** [Text, Markdown, API calls, Shell commands, Configuration, Guidance] <br>
**Output Format:** [Markdown or plain text with Tencent Meeting data, trace identifiers, and optional shell command examples] <br>
**Output Parameters:** [1D] <br>
**Other Properties Related to Output:** [Requires python3 and the TENCENT_MEETING_TOKEN environment variable.] <br>

## Skill Version(s): <br>
1.0.8 (source: server release evidence and artifact config.json) <br>

## Ethical Considerations: <br>
Users should evaluate whether this skill is appropriate for their environment, review any generated or modified files before relying on them, and apply their organization's safety, security, and compliance requirements before deployment. <br>
