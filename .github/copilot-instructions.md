# Copilot Instructions for AI Coding Agents

## Project Overview

- **Purpose**: This agent processes video URLs (ScreenPal, YouTube, Twitch, S3) to produce synchronized audio transcriptions, visual analyses, and unified markdown documents.
- **Pipeline**: Audio extraction/transcription (Whisper), frame extraction (FFmpeg), visual analysis (Moondream2 via Ollama), and unified document generation.
- **Outputs**: JSON, Markdown, and PNG frames in `~/Downloads/video-transcripts-{timestamp}/`.

## Architecture & Data Flow

- **Kiro CLI**: Entry point for agent chat and orchestration.
- **MCP Servers**: Modular services for video/audio/vision tasks, configured globally in `~/.kiro/settings/mcp.json` and per-agent in `~/.kiro/agents/screenpal-video-transcriber.json`.
- **Key Tools**: `yt-dlp`, `ffmpeg`, `OpenAI Whisper`, `Ollama` (with Moondream2), Perl for automation.
- **Data Flow**: URL → Audio/Frame Extraction → Transcription/Visual Analysis → Unified Output.

## Critical Workflows

- **Setup**: Run `chmod +x setup.pl && ./setup.pl` to install dependencies, configure MCP servers, and verify environment.
- **Agent Launch**: `kiro-cli chat --agent screenpal-video-transcriber` from the project directory.
- **Processing**: Provide a supported video URL; agent auto-detects platform and runs the full pipeline.
- **Outputs**: All results are stored in a timestamped directory under `~/Downloads/`.

## Project-Specific Conventions

- **Unified Workflow**: All steps (audio, visual, document) are handled in a single agent request—no manual tool selection.
- **Configuration**: MCP servers and agent profiles are JSON files in user home (`~/.kiro/`).
- **Perl Scripts**: Used for setup and verification (`setup.pl`, `verify-config.pl`).
- **Knowledge Base**: See `knowledge/` for platform docs, best practices, and troubleshooting.
- **Output Redirection**: MCP servers must not print to stdout before JSON-RPC handshake (see `docs/ARCHITECTURE.md`).

## Integration & Dependencies

- **yt-dlp**: For media extraction from URLs.
- **FFmpeg**: For audio/frame extraction and scene detection.
- **OpenAI Whisper**: For speech-to-text.
- **Ollama + Moondream2**: For local vision-language analysis.
- **Kiro CLI**: For agent orchestration and tool management.

## Key Files & Directories

- `setup.pl`, `verify-config.pl`: Automation and environment checks.
- `docs/ARCHITECTURE.md`: System design and data flow.
- `docs/TROUBLESHOOTING.md`: Common issues and solutions.
- `knowledge/`: Agent workflows, platform integration, best practices.
- `reference/agent-config.json`, `reference/mcp-config.json`: Example config files.

## Examples

- To process a video: `Please transcribe this ScreenPal video: https://go.screenpal.com/[video-id]`
- To debug: Run `verify-config.pl` or check `docs/TROUBLESHOOTING.md`.

## Security & Privacy

- All processing is local; no cloud APIs are used.
- Only validated URLs (ScreenPal, YouTube, Twitch, S3) are accepted.
- File writes are restricted to designated output directories.

---

For more, see `README.md`, `docs/ARCHITECTURE.md`, and `knowledge/`.
