/* This file is part of the Razor AHRS Firmware */

// Output angles: yaw, pitch, roll
void output_angles()
{
  if (output_format == OUTPUT__FORMAT_BINARY)
  {
    float ypr[3];  
    ypr[0] = TO_DEG(yaw);
    ypr[1] = TO_DEG(pitch);
    ypr[2] = TO_DEG(roll);
    mySerial.write((byte*) ypr, 12);  // No new-line
  }
  else if (output_format == OUTPUT__FORMAT_TEXT)
  {
    mySerial.print("#YPR=");
    mySerial.print(TO_DEG(yaw)); mySerial.print(",");
    mySerial.print(TO_DEG(pitch)); mySerial.print(",");
    mySerial.print(TO_DEG(roll)); mySerial.print(",");
    mySerial.print(sqrt(accel[0] * accel[0] + accel[1] * accel[1] + accel[2] * accel[2])); mySerial.print(","); // G-force = accel vector magnitude
    mySerial.print(accel[0]); mySerial.print(",");
   mySerial.print(accel[1]); mySerial.print(",");
  mySerial.print(accel[2]); mySerial.println(",");
}


// IF useSD is set, then also write to SD
if(useSD == 1){
  
  File dataFile = SD.open("datalog.txt", FILE_WRITE);
  // if the file is available, write to it:
  if (dataFile) {
    dataFile.print("#YPR=");
    dataFile.print(TO_DEG(yaw)); dataFile.print(",");
    dataFile.print(TO_DEG(pitch)); dataFile.print(",");
    dataFile.print(TO_DEG(roll)); dataFile.print(",");
    dataFile.print(sqrt(accel[0] * accel[0] + accel[1] * accel[1] + accel[2] * accel[2])); dataFile.print(","); // G-force = accel vector magnitude
    dataFile.print(accel[0]); dataFile.print(",");
    dataFile.print(accel[1]); dataFile.print(",");
    dataFile.print(accel[2]); dataFile.print(","); dataFile.print(millis()); dataFile.println(",");
    dataFile.close();
    // print to the serial port too
  }
}




}

void output_calibration(int calibration_sensor)
{
  if (calibration_sensor == 0)  // Accelerometer
  {
    // Output MIN/MAX values
    mySerial.print("accel x,y,z (min/max) = ");
    for (int i = 0; i < 3; i++) {
      if (accel[i] < accel_min[i]) accel_min[i] = accel[i];
      if (accel[i] > accel_max[i]) accel_max[i] = accel[i];
      mySerial.print(accel_min[i]);
      mySerial.print("/");
      mySerial.print(accel_max[i]);
      if (i < 2) mySerial.print("  ");
      else mySerial.println();
    }
  }
  else if (calibration_sensor == 1)  // Magnetometer
  {
    // Output MIN/MAX values
    mySerial.print("magn x,y,z (min/max) = ");
    for (int i = 0; i < 3; i++) {
      if (magnetom[i] < magnetom_min[i]) magnetom_min[i] = magnetom[i];
      if (magnetom[i] > magnetom_max[i]) magnetom_max[i] = magnetom[i];
      mySerial.print(magnetom_min[i]);
      mySerial.print("/");
      mySerial.print(magnetom_max[i]);
      if (i < 2) mySerial.print("  ");
      else mySerial.println();
    }
  }
  else if (calibration_sensor == 2)  // Gyroscope
  {
    // Average gyro values
    for (int i = 0; i < 3; i++)
      gyro_average[i] += gyro[i];
    gyro_num_samples++;
      
    // Output current and averaged gyroscope values
    mySerial.print("gyro x,y,z (current/average) = ");
    for (int i = 0; i < 3; i++) {
      mySerial.print(gyro[i]);
      mySerial.print("/");
      mySerial.print(gyro_average[i] / (float) gyro_num_samples);
      if (i < 2) mySerial.print("  ");
      else mySerial.println();
    }
  }
}

void output_sensors_text(char raw_or_calibrated)
{
  mySerial.print("#A-"); mySerial.print(raw_or_calibrated); mySerial.print('=');
  mySerial.print(accel[0]); mySerial.print(",");
  mySerial.print(accel[1]); mySerial.print(",");
  mySerial.print(accel[2]); mySerial.println();

  mySerial.print("#M-"); mySerial.print(raw_or_calibrated); mySerial.print('=');
  mySerial.print(magnetom[0]); mySerial.print(",");
  mySerial.print(magnetom[1]); mySerial.print(",");
  mySerial.print(magnetom[2]); mySerial.println();

  mySerial.print("#G-"); mySerial.print(raw_or_calibrated); mySerial.print('=');
  mySerial.print(gyro[0]); mySerial.print(",");
  mySerial.print(gyro[1]); mySerial.print(",");
  mySerial.print(gyro[2]); mySerial.println();
}

void output_sensors_binary()
{
  mySerial.write((byte*) accel, 12);
  mySerial.write((byte*) magnetom, 12);
  mySerial.write((byte*) gyro, 12);
}

void output_sensors()
{
  if (output_mode == OUTPUT__MODE_SENSORS_RAW)
  {
    if (output_format == OUTPUT__FORMAT_BINARY)
      output_sensors_binary();
    else if (output_format == OUTPUT__FORMAT_TEXT)
      output_sensors_text('R');
  }
  else if (output_mode == OUTPUT__MODE_SENSORS_CALIB)
  {
    // Apply sensor calibration
    compensate_sensor_errors();
    
    if (output_format == OUTPUT__FORMAT_BINARY)
      output_sensors_binary();
    else if (output_format == OUTPUT__FORMAT_TEXT)
      output_sensors_text('C');
  }
  else if (output_mode == OUTPUT__MODE_SENSORS_BOTH)
  {
    if (output_format == OUTPUT__FORMAT_BINARY)
    {
      output_sensors_binary();
      compensate_sensor_errors();
      output_sensors_binary();
    }
    else if (output_format == OUTPUT__FORMAT_TEXT)
    {
      output_sensors_text('R');
      compensate_sensor_errors();
      output_sensors_text('C');
    }
  }
  

  
  
}

