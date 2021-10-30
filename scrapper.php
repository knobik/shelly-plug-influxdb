<?php

use GuzzleHttp\Client;
use InfluxDB\Database;
use InfluxDB\Point;

require __DIR__ . '/vendor/autoload.php';

function env(string $name, $default = null)
{
    $value = getenv($name);
    return $value === false ? $default : $value;
}

$plugName = env('SHELLY_PLUG_NAME', 'plug1');
$plugHost = env('SHELLY_PLUG_IP');
$plugUser = env('SHELLY_PLUG_USER');
$plugPassword = env('SHELLY_PLUG_PASSWORD');

$dbHost = env('INFLUXDB_HOST', 'influxdb');
$dbPort = env('INFLUXDB_PORT', 8086);
$dbName = env('INFLUXDB_DB', 'shelly-plug');
$dbUser = env('INFLUXDB_ADMIN_USER');
$dbPassword = env('INFLUXDB_ADMIN_PASSWORD');

if (!$dbUser || !$dbPassword) {
    throw new Exception('Please provide INFLUXDB_ADMIN_USER and INFLUXDB_ADMIN_PASSWORD');
}

$dbClient = new \InfluxDB\Client($dbHost, $dbPort, $dbUser, $dbPassword);
$database = $dbClient->selectDB($dbName);
if (!$database->exists()) {
    $database->create();
}

$client = new Client();
$response = $client->get("http://{$plugHost}/status", [
    'auth' => [$plugUser, $plugPassword]
]);

$data = json_decode($response->getBody()->getContents(), false, 512, JSON_THROW_ON_ERROR);
$meter = $data->meters[0];

$fields = [
    'power' => $meter->power,
    'total' => $meter->total,
    'temperature' => $data->temperature,
    'uptime' => $data->uptime,
    'active' => $data->relays[0]->ison ? 1 : 0
];

$points = [];
foreach ($fields as $name => $value) {
    $points[] = new Point(
        $name,
        $value,
        [ 'name' => $plugName, 'ip' => $plugHost ],
        [],
        $meter->timestamp
    );
}

$database->writePoints($points, Database::PRECISION_SECONDS);