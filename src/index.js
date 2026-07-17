const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Obtenemos el color del entorno (inyectado desde el Deployment)
const color = process.env.DEPLOY_COLOR || 'Blue';

app.get('/health', (req, res) => {
  // Esta respuesta es la que espera tu pipeline en el 'grep' de validación
  res.status(200).json({ status: 'OK', message: 'Orders service is healthy' });
});

app.get('/', (req, res) => {
  // Ahora la respuesta es dinámica y refleja qué versión está activa
  res.status(200).send(`TechMarket Orders API - Versión ${color}`);
});

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Server running on port ${port} [Color: ${color}]`);
  });
}

module.exports = app;
