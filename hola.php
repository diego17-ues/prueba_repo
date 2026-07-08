<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Mi primer script</title>
</head>
<body>

    <h1><?php echo "¡Hola, mundo desde PHP!"; ?></h1>
    <p>
        <?php
            date_default_timezone_set('America/Bogota');
            echo "Fecha y hora actual: " . date('d/m/Y H:i:s');
        ?>
            echo "<br>País: El Salvador";
    </p>

</body>
</html>