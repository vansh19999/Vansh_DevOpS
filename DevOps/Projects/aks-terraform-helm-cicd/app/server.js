const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (_, res) => {
  res.json({ ok: true, service: 'orders-api', time: new Date().toISOString() });
});

app.listen(port, () => console.log(`orders-api listening on ${port}`));
