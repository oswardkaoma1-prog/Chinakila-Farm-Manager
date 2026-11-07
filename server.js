import express from 'express';
import cors from 'cors';
import 'dotenv/config';

const app = express();
app.use(cors());
app.use(express.json());

const base = (process.env.KOBO_BASE_URL || 'https://kf.kobotoolbox.org').replace(/\/$/, '');
const token = process.env.KOBO_API_TOKEN;
const asset = process.env.KOBO_ASSET_UID;

app.get('/health', (_req, res) => res.json({ ok: true, service: 'Chinakila integration server' }));

app.get('/api/submissions', async (_req, res) => {
  if (!token || !asset) return res.status(503).json({ error: 'Kobo connection is not configured yet.' });
  try {
    const response = await fetch(`${base}/api/v2/assets/${encodeURIComponent(asset)}/data/`, {
      headers: { Authorization: `Token ${token}`, Accept: 'application/json' }
    });
    const body = await response.text();
    res.status(response.status).type(response.headers.get('content-type') || 'application/json').send(body);
  } catch (error) {
    res.status(502).json({ error: 'Could not reach KoboToolbox', detail: error.message });
  }
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => console.log(`Chinakila integration server listening on ${port}`));
