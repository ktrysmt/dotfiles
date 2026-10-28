# Provenance of artifacts

- Classify every existing artifact by provenance before using it: user-decided / agreed elsewhere (Slack, design docs; cite the URL) / agent-drafted. Agent-drafted code, trees and proposals carry no authority.
- Never use an agent-drafted artifact as the baseline of a comparison. Derive the target state from requirements and agreed docs first; express the current code only as the diff to fix.
- Do not present pros/cons when one side has no rationale. State the target state.
- Before presenting a structural change (move, split, duplicate), read the moved files and check names, references and uniqueness under the new structure.
- Questions must not embed unverified assumptions in their options. Check the agreed source first.