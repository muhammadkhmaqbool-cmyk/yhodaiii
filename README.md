# YHOD — upload pack (no folders)

**YHOD — Your Health, Our Duty.** This is the whole site as 8 loose files. There are no folders, so it can
be uploaded to GitHub with "choose your files" or from a phone.

| File | What it is |
| --- | --- |
| `server.js` | The whole server in one file, with the pages, styles, fonts and voice lines packed inside it. Made by a tool — do not edit it by hand. |
| `package.json` | Says "ES modules, Node 24". There is nothing to install. |
| `vercel.json` | Tells Vercel to run `server.js` for every address. |
| `.env.example` | The settings YHOD understands. |
| `.gitignore`, `.vercelignore` | Keep secrets out of uploads. |
| `run.sh` | Starts YHOD on a computer. |

## Put it online: GitHub → Vercel

1. In your GitHub repository choose **Add file → Upload files**, select **all 8 files** of this folder and press
   **Commit changes**. Files with the same name are replaced.
   The three that matter are `server.js`, `package.json` and `vercel.json`.
2. In Vercel open the project → **Settings → Environment Variables** and add `GEMINI_API_KEY` with your key
   from <https://aistudio.google.com/apikey>.
3. **Deployments → ⋯ → Redeploy**, if you added or changed the key after uploading. A site only sees a new
   key after it was deployed again.
4. Open your site. It works at once. `https://your-site.vercel.app/api/status` should say
   `"ai":{"name":"YHOD AI","configured":true,"ok":true`.

On the site the AI is called **YHOD AI** everywhere. Visitors never see the name of the service behind it;
only the setting `GEMINI_API_KEY` keeps its name, because that is what Vercel has to be given.

### Where workspaces are kept

**Without a database (nothing to set up):** each person's workspace is kept in their own browser, sealed so
that only this site can open it. The sign-in page says so. It opens again on the next visit without asking for
the e-mail and password. But it exists only in that browser: on another phone or computer the same e-mail
starts a new workspace, and clearing the browser's data removes it. Photos are not saved. `/api/status` shows
`"kind":"device"`. Do not replace `GEMINI_API_KEY` later without need: the workspaces in people's browsers
are sealed with a key made from it, and could no longer be opened (setting `YHOD_DATA_KEY` once avoids that).

**With a database (optional, free):** workspaces are kept on the server side and open from every device. In
the Vercel project open **Storage → Create Database → Turso**, follow its steps (the free plan is enough),
connect the database to the project, then **Deployments → ⋯ → Redeploy**. `/api/status` then shows
`"durable":true`. Workspaces made before that stay in their browsers; they are not moved.

**Never upload a file called `.env`.** The key belongs in Vercel's Environment Variables only. Google switches
off keys that it finds in public places.

## Run it on a computer

```bash
cp .env.example .env        # then put your Gemini key into .env
node server.js              # Node 22.13 or newer — or: sh run.sh
```

Open `http://localhost:3000`. Records are written to a `data` folder next to `server.js`.

---
Pack 52527e425ce8, made 2026-11-17 17:20 UTC. YHOD gives general health information, not medical advice.
