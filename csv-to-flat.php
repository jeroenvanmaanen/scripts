#!/usr/bin/php -f
<?php

$arguments = $argv;
array_shift($arguments);

// echo "ARGV[0]=[$argv[0]]\n";
// echo "ARGUMENTS[0]=[$arguments[0]]\n";

$sep = ',';
if ($arguments[0] == '-d') {
	$dummy = array_shift($arguments);
	$sep = array_shift($arguments);
}
// echo "SEP=[$sep]\n";
$key_indices = array(1);
if ($arguments[0] == '-k') {
	array_shift($arguments);
	$key_indices = explode(',', array_shift($arguments));
}

$string_content_re = '([^"]|"")*';
$field_re = '("' . $string_content_re . '"|[^' . $sep . '"]*)[' . $sep . "\n]";
$pattern = '/' . $field_re . '/';
// echo 'PATTERN: [' . $pattern . "]\n";
$incomplete_pattern = '/^(' . $field_re . ')*"' . $string_content_re . '$/';

$input_file = fopen('php://stdin', 'r');
$output_file = fopen('php://stdout', 'w');

function format_record($field_names, $record) {
	$fields = array();
	$first = True;
	foreach ($field_names as $field_name) {
		$field = $record[$field_name];
		if ($field) {
			$field = '"' . preg_replace('/"/', '""', $field) . '"';
		}
		array_push($fields, $field);
	}
	return implode(',', $fields);
}

function fgetcleans($file) {
	$line = fgets($file);
	$len = strlen($line);
	if ($len > 1 && substr($line, $len - 2) == "\r\n") {
		$line = substr($line, 0, $len - 2) . "\n";
	}
	return $line;
}

$field_names = array('?');
$first = true;

while ($line = fgetcleans($input_file)) {
	while (preg_match($incomplete_pattern, $line) > 0) {
		$line = $line . fgetcleans($input_file);
//		echo '>>> ' . $line;
	}
//	echo '>>> ' . substr(rtrim($line), 0, 60) . "\n";
	$pos = 0;
	$fields = array();
	$matches = array();
	while (preg_match($pattern, $line, $matches, PREG_OFFSET_CAPTURE, $pos) > 0) {
		$match = $matches[1];
		if ($match[1] != $pos) {
			echo "ERROR: " . $pos . ": " . print_r($matches, true) . "[" . substr($line, $pos) . "]\n";
			exit(1);
		}
//		print_r($match);
		$field = $match[0];
//		echo '1.Field: [' . $field . "]\n";
//		echo '[' . substr($field, 0, 1) . "]\n";
		if (substr($field, 0, 1) == '"') {
//			echo "String!\n";
			$field = substr($field, 1, strlen($field) - 2);
		}
//		echo '2.Field: [' . $field . "]\n";
		$field = preg_replace('/""/', '"', $field);
//		echo '  Field: [' . $field . "]\n";
		$pos = $pos + strlen($matches[0][0]);
		array_push($fields,$field);
	}
	if ($first) {
		$field_names = $fields;
		$first = false;
	} else {
		$prefix = array();
		foreach ($key_indices as $key_index) {
			$prefix[] = $fields[$key_index - 1];
		}
		$prefix = implode('/', $prefix);
		foreach ($fields as $column_index => $value) {
		    $column_nr = $column_index + 1;
			$column_name = $field_names[$column_index];
			$line_prefix = "${prefix}[$column_nr:$column_name]";
			if (strpos($value, "\n")) {
				$lines = explode("\n", $value);
				foreach ($lines as $line_idx => $line) {
					$line_nr = $line_idx + 1;
					fwrite($output_file, "$line_prefix:$line_nr: $line\n");
				}
			} else {
				fwrite($output_file, "$line_prefix:: $value\n");
			}
		}
		fwrite($output_file, "\n");
	}
}

fclose($output_file);
fclose($input_file);

?>
