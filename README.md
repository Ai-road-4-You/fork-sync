# iAiFy Fork Sync

Automated upstream synchronization for managed forks across iAiFy organizations.

## Managed Forks

AiFeatures maintains 24 forks, AiProducting maintains 1 fork.

## Sync Strategy

- **Automated**: GitHub's built-in "Fetch upstream" for simple tracking forks
- **Manual**: For forks with local modifications, use controlled merge workflow
- **Scheduled**: Weekly sync check via GitHub Actions

## Usage

The sync workflow runs weekly and creates PRs for any upstream changes.
