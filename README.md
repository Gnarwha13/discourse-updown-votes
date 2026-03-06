# discourse-updown-votes

A Discourse plugin that adds **up/downvoting** to both the topic list preview and individual posts, with per-user score tracking.

---

## Features

| Location | What you get |
|---|---|
| Topic list | ▲ score ▼ displayed after each topic title |
| Topic page (posts) | ▲ score ▼ in the post action menu of every post |
| User profile | Cumulative vote score across all their topics & posts |

- **Toggle behaviour** – clicking the same arrow again removes your vote.  
- **Live score** – score updates instantly in the UI without a page reload.  
- **Trust-level gate** – optional minimum trust level to cast votes (site setting).  
- **Anonymous view** – scores are visible to guests; voting requires login.

---

## Installation

### Manual (self-hosted)

```bash
# From your Discourse root
cd /var/discourse
./launcher enter app

# Inside the container
cd /var/www/discourse
git clone https://github.com/your-org/discourse-updown-votes.git plugins/discourse-updown-votes

# Rebuild
exit
./launcher rebuild app
```

### app.yml (recommended)

Add to the `hooks > after_code` section of `/containers/app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/your-org/discourse-updown-votes.git
```

Then run `./launcher rebuild app`.

---

## Site Settings

| Setting | Default | Description |
|---|---|---|
| `updown_votes_enabled` | `true` | Master on/off switch |
| `updown_votes_anonymous_view` | `true` | Show scores to logged-out users |
| `updown_votes_require_trust_level` | `0` | Minimum trust level to cast a vote |

---

## Database Schema

```
updown_votes
  id            integer  PK
  user_id       integer  FK → users
  votable_type  string   "Topic" or "Post"
  votable_id    integer
  direction     string   "up" or "down"
  created_at    datetime
  updated_at    datetime

  UNIQUE INDEX (user_id, votable_type, votable_id)
```

---

## API

### Cast / toggle a vote
```
POST /updown-votes
  votable_type  Topic | Post
  votable_id    <integer>
  direction     up | down

→ { direction: "up"|"down"|null, score: <integer> }
```

### Remove a vote
```
DELETE /updown-votes
  votable_type  Topic | Post
  votable_id    <integer>

→ { direction: null, score: <integer> }
```

### Get a user's total score
```
GET /updown-votes/scores?user_id=<integer>

→ { score: <integer> }
```

---

## Architecture

```
plugin.rb                          ← registration & serializer extensions
config/settings.yml                ← site settings
db/migrate/…_create_updown_votes   ← schema

app/
  models/updown_vote.rb            ← ActiveRecord model + score helpers
  controllers/updown_votes_controller.rb

assets/javascripts/discourse/
  initializers/updown-votes.js     ← plugin-api bootstrap
  components/
    updown-vote-buttons.js         ← Glimmer component (state + ajax)
    updown-vote-buttons.hbs        ← template
  connectors/
    topic-list-after-title/        ← injects buttons into topic list rows
    post-menu/                     ← injects buttons into post action bar

assets/stylesheets/updown-votes.scss
```

---

## Contributing / Customising

- To move the topic-list buttons, change the connector folder name to any valid Discourse outlet (`topic-list-before-columns`, `topic-list-after-columns`, etc.).
- Score weighting (e.g. upvote = +2) can be changed in `UpdownVote.score_for_*` methods.
