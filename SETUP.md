# X Buddy — New System Setup Guide

## What is X Buddy?
A smart web app for students to upload PDFs, configure print settings, pay via UPI QR, and auto-print. Built with React + Vite (frontend) and Node.js (print agent).

---

## STEP 1 — Install Required Software

- [Node.js LTS](https://nodejs.org) — download and install
- [Git](https://git-scm.com) — download and install

Verify after install by opening CMD and running:
```
node --version
git --version
```

---

## STEP 2 — Clone the Repository

Open CMD and run:
```
git clone https://github.com/uddagiriabhiram/buddy.git
cd buddy
```

---

## STEP 3 — Copy These Files Manually

These files are NOT in GitHub (secret/binary). Copy them into the project:

| File | Where to put it |
|------|----------------|
| `credentials.json` | `X buddy server\startserver\credentials.json` |
| `cloudflared.exe` | `X buddy server\startserver\cloudflared.exe` |
| `qr-code.png` | `public\qr-code.png` |

> Get `credentials.json` from: https://console.cloud.google.com/iam-admin/serviceaccounts
> Project: flash-direction-496513-f6
> Service Account: xbuddy-print-agent-401@flash-direction-496513-f6.iam.gserviceaccount.com
> Keys tab → Add Key → Create new key → JSON → download → rename to credentials.json

> Get `cloudflared.exe` from: https://github.com/cloudflare/cloudflared/releases/latest
> Download: cloudflared-windows-amd64.exe → rename to cloudflared.exe

---

## STEP 4 — Install Dependencies

**Frontend:**
```
cd buddy
npm install
```

**Print Agent:**
```
cd "X buddy server\startserver"
npm install
```

---

## STEP 5 — Run the First-Time Setup Script

Double-click `FIRST TIME SETUP.bat` — it will:
- Auto-detect your Windows username
- Fix all paths in START X BUDDY.bat
- Confirm everything is ready

---

## STEP 6 — Start Everything

Double-click `START X BUDDY.bat` every session.

It will automatically:
1. Start Cloudflare tunnel
2. Detect tunnel URL and update api.js
3. Push updated api.js to GitHub
4. Start print agent (polls every 5s)
5. Open website at http://localhost:5173

---

## Project Structure

```
buddy/                          ← Frontend (React + Vite)
├── src/
│   ├── App.jsx                 ← Main app, step flow
│   ├── components/
│   │   ├── Hero.jsx            ← Landing page
│   │   ├── UploadSection.jsx   ← PDF drag & drop
│   │   ├── PrintSettings.jsx   ← Color/side/copies
│   │   ├── PriceCard.jsx       ← Price + Pay button
│   │   ├── PaymentModal.jsx    ← QR code modal
│   │   ├── PaymentProofForm.jsx← Phone + TxID + screenshot
│   │   └── PrintStatus.jsx     ← Real-time print status
│   └── utils/
│       ├── api.js              ← GAS + local agent calls
│       ├── pricing.js          ← Cost calculation
│       └── fileToBase64.js     ← File converter
├── public/
│   └── qr-code.png             ← YOUR UPI QR (add manually)
├── START X BUDDY.bat           ← Master startup script
└── FIRST TIME SETUP.bat        ← Run once on new system

X buddy server/startserver/     ← Print Agent (Node.js)
├── index.js                    ← Polls Sheets every 5s
├── services/
│   ├── localServer.js          ← Express on port 3001
│   ├── sheets.js               ← Read waiting orders
│   ├── updater.js              ← Update print status
│   └── printer.js              ← Send to printer
├── credentials.json            ← ADD MANUALLY (secret)
└── cloudflared.exe             ← ADD MANUALLY (binary)
```

---

## Backend Details

| Service | Details |
|---------|---------|
| Google Apps Script | https://script.google.com/macros/s/AKfycbyj8UTgncnMmmz4ERZIN49PiHqPOS2GnBABOKgQ9WEirPh8aHSt0tdCcKkv2nUqeKt9/exec |
| Google Sheet ID | 16R6KiGoNgH31qEJxCiKrNTD2u99TKHJfDlzgb6iH_nw |
| Sheet Columns | Order ID, Name, File Name, Total Pages, Copies, Print Type, Print Side, Amount, Transaction ID, Print Status, Timestamp |

---

## Pricing

| Type | Rate |
|------|------|
| B&W | ₹2 per page |
| Color | ₹5 per page |
| Double side | Halves page count |

---

## Every Session Checklist

- [ ] Run START X BUDDY.bat
- [ ] Confirm tunnel URL detected
- [ ] Confirm print agent window shows "Polling every 5s"
- [ ] Open http://localhost:5173

---

## Troubleshooting

**Tunnel URL not detected:**
- Look at the minimized "Cloudflare Tunnel" window in taskbar
- Copy the trycloudflare.com URL manually and paste when prompted

**Print agent crashes:**
- Check credentials.json is in `X buddy server\startserver\`
- Make sure Google Sheet is shared with: xbuddy-print-agent-401@flash-direction-496513-f6.iam.gserviceaccount.com

**Website not loading:**
- Make sure npm install was run in the buddy folder
- Check http://localhost:5173 in browser manually

**Orders stuck on Waiting:**
- Print agent must be running
- Cloudflare tunnel must be active
- credentials.json must be valid
