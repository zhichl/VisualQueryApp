<?php

/**
 * Created by PhpStorm.
 * User: Nebul
 * Date: 04/11/2016
 * Time: 16:51
 */
class DbConnect
{
    private $conn;

    function __construct()
    {
    }

    /**
     * Establishing database connection
     * @return database connection handler
     */
    function connect()
    {
        require_once 'Config.php';

        // Connecting to mysql database
        $this->conn = new mysqli(DB_HOST, DB_USERNAME, DB_PASSWORD, DB_NAME);

        // Check for database connection error
        if (mysqli_connect_errno()) {
            echo "Failed to connect to MySQL: " . mysqli_connect_error();
        }

        // returing connection resource
        return $this->conn;
    }
}