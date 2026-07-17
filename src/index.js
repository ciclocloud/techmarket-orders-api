const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Orders service is healthy' });
});

app.get('/', (req, res) => {
  res.status(200).send('TechMarket Orders API - Versión Blue');
});

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

module.exports = app;
