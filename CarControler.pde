class CarController {
  
                Car bil                    ;
                NeuralNetwork hjerne       ;
                SensorSystem  sensorSystem ;
  
  CarController(float [] LowerWeight, float [] HigherWeight, float [] LowerBias, float [] HigherBias){
                bil          = new Car();
                hjerne       = new NeuralNetwork(LowerWeight, HigherWeight, LowerBias, HigherBias); 
                sensorSystem = new SensorSystem();
  }
                
  void update() {
    //1.)opdtarer bil 
    bil.update();
    //2.)opdaterer sensorer    
    sensorSystem.updateSensorsignals(bil.pos, bil.vel);
    //3.)hjernen beregner hvor meget der skal drejes
    float turnAngle = 0;
    float x1 = (float)int(sensorSystem.leftSensorSignal);
    float x2 = (float)int(sensorSystem.frontSensorSignal);
    float x3 = (float)int(sensorSystem.rightSensorSignal);    
    turnAngle = hjerne.getOutput(x1, x2, x3);    
    //4.)bilen drejes
    bil.turnCar(turnAngle);
  }
  
  void display(){
    bil.displayCar();
    sensorSystem.displaySensors();
    }
  }
