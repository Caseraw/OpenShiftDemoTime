const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();

app.get('/', (req, res) => {
  fs.readFile(path.join(__dirname, 'public', 'index.html'), 'utf8', (err, data) => {
    if (err) return res.status(500).send('Error loading page');
    const backendUrl = process.env.BACKEND_URL || '';
    res.send(data.replace('<BACKEND_API_URL>', backendUrl));
  });
});

app.use(express.static('public'));

app.listen(8080, () => {
  console.log('Frontend running on http://0.0.0.0:8080');
});
