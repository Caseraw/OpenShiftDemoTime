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

// /onboard-tenant slash command
// only VMS for the sake of demo the concept
app.post("/vm", (req, res, next) => {
    console.log(req.body);
    var data = {
        "tenant": req.body.text,
        "action": "create"
    };
    var args = {
        data: data,
        "message": req.body.text + " VMs are being deployed",
        "tenant": req.body.text,
        headers: { "Content-Type": "application/json" }
    };
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
