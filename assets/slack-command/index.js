var express = require("express")
var Client = require('node-rest-client').Client;

var app = express()
var client = new Client();

app.use(express.text());

var bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: false }));

// Server port
var HTTP_PORT = 8080

// Start server
app.listen(HTTP_PORT, () => {
    console.log("Server running on port %PORT%".replace("%PORT%", HTTP_PORT))
});

// /onboard-user slash command
app.post("/vm", (req, res, next) => {
    console.log(req.body);
    var data = {
        "tenant": req.body
    };
    var args = {
        data: data,
        "message": req.body + " VMs are being deployed",
        "tenant": req.body,
        headers: { "Content-Type": "application/json" }
    };
    console.log(args);
    client.post("http://el-vm-as-a-service-event-listener-cicd.apps.cluster-sfhmt.sfhmt.sandbox587.opentlc.com",
        args,
        function (response_data, response) {
            console.log(response_data);
            res.json(data);
        });
})


app.get("/", (req, res, next) => {
    res.json({
        "message": "success",
        "data": "Hello ChatOps"
    })

})
