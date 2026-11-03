RPG Adventure — Supabase Online Setup (Milestone 1)
===================================================

FILES
- rpg_supabase_online.html : original game plus the first Supabase integration
- supabase_setup.sql       : database tables, leaderboard view, and RLS policies

1) CREATE A SUPABASE PROJECT
- Create a project at https://supabase.com/dashboard
- Open SQL Editor > New query.
- Paste and run the entire supabase_setup.sql file.

2) CONFIGURE USERNAME/PASSWORD LOGIN
This game exposes username + password fields. Internally it maps each normalized
username to a deterministic synthetic address ending in @players.invalid so it
can use Supabase Auth without asking the player for an email address.
- In Authentication > Providers > Email, turn OFF Confirm email.
- Keep password authentication enabled.
- Passwords must be at least 8 characters.
- Username-only login has no self-service email password reset. Plan a verified
  account recovery process before production launch.

3) ADD PROJECT KEYS TO THE HTML
Open rpg_supabase_online.html in a text editor and find:
  const SUPABASE_URL='https://YOUR_PROJECT.supabase.co';
  const SUPABASE_ANON_KEY='YOUR_SUPABASE_ANON_KEY';
Replace these with the Project URL and the anon/publishable key shown in
Supabase Dashboard > Project Settings > API. Never put the service_role key in
this HTML file.

4) HOST THE GAME
- Serve the HTML over HTTPS (for example, a static hosting provider).
- Do not open it as file:// if you want authentication/realtime to work reliably.
- Share the same game URL with all players.

5) FIRST LOGIN AND OLD SAVE MIGRATION
- Open the hosted game, create a username/password account, then choose a
  character class.
- If a local browser save exists when you first sign in to a new account, the
  game attempts to copy it into that account's cloud save.
- On another device, sign in using the same username/password to load that save.
- Existing legacy local password hashes are not used as account credentials.

WHAT THIS MILESTONE CONNECTS
- Supabase Auth username/password login (synthetic email mapping)
- Private per-user cloud save with Row Level Security
- Public leaderboard backed by player_stats + leaderboard view
- Realtime world presence (players appear on the existing game map)
- Realtime party room presence and reward sharing prototype
- PvP damage broadcast prototype
- Persistent guilds and membership
- Event schedule listing from game_events

IMPORTANT LIMITATIONS BEFORE PUBLIC LAUNCH
- Game saves, player power, EXP, gold, party rewards, and PvP are currently
  client-authoritative. RLS protects one account's rows from another account,
  but a modified browser can still cheat in its own save/stats. A production
  economy requires trusted Edge Functions/server validation for rewards,
  inventory, damage, guild creation, and leaderboard updates.
- Party EXP/gold sharing is a prototype broadcast, not server-verified.
- PvP currently broadcasts damage events; it is not a server-authoritative
  combat simulation or anti-cheat system.
- Events can be displayed after rows are added by an administrator in the
  Supabase dashboard/SQL editor. A timed World Boss and event reward claims
  still need server-side event logic.
- Guild permissions are intentionally basic in this first pass. Leadership
  transfer, invitations, moderation, and guild chat are not yet implemented.
- Do not expose the Supabase service_role key in the client.

TEST CHECKLIST
[ ] Run supabase_setup.sql successfully
[ ] Set project URL and anon/publishable key in the HTML
[ ] Disable Email confirmations
[ ] Host the file over HTTPS
[ ] Register a test username and create a character
[ ] Reload and verify the cloud save loads
[ ] Sign in from another browser/device and verify the same character loads
[ ] Open two sessions and verify players appear in the same map
[ ] Create/join a party and verify presence
[ ] Verify leaderboard and guild creation/join
