PFont f; 

// Laver lister til henholdsvis den højere og lavere værdi af weights og bias, så de individuelle værdier kan bestemmes senere
float [] LowerWeight             = {-2, -2, -2, -2, -2, -2, -2, -2};
float [] HigherWeight            = {2, 2, 2, 2, 2, 2, 2, 2};
float [] LowerBias               = {-2, -2, -2};
float [] HigherBias              = {2, 2, 2};

// Laver varians og gennemsnit af weight/bias, som kommer til at være afhængige af hvilke biler der klarede sig godt i de foreløbende iterationer
float varians                    = 2;
float [] weightAv                = new float[8];
float [] biasAv                  = new float[3];

//populationSize: Hvor mange "controllere" der genereres, controller = bil & hjerne & sensorer
int       populationSize  = 100;     

//fitness for hver enkelt bil
float [] fitnessList = new float [populationSize];
float totalFitness;

//CarSystem: Indholder en population af "controllere" 
CarSystem carSystem       = new CarSystem(populationSize, LowerWeight, HigherWeight, LowerBias, HigherBias);

//trackImage: RacerBanen , Vejen=sort, Udenfor=hvid, Målstreg= 100%grøn 
PImage    trackImage;

void setup() {
  size(700, 700);
  trackImage = loadImage("track.png");
  f = createFont("Arial",16,true);
}

void draw() {
  clear();
  fill(255);
  rect(0, 0, 1000, 1000);
  image(trackImage, 0, 80);  
  textFont(f,16);
  fill(255, 0, 0); 
  text("I starten bliver bilerne placeret random, og efter et par runder bliver de klogere og klogere", 10, 600);
  text("og til sidst følger de alle den sorte racerbane", 10, 615);

  carSystem.updateAndDisplay();

  ////TESTKODE: Frastortering af dårlige biler, for hver gang der går 200 frame - f.eks. dem der kører uden for banen. Stopper når der er 20 biler tilbage.
  if (frameCount%100==0) {
    for (int i = carSystem.CarControllerList.size()-1; i >= 0; i--) {
      SensorSystem s = carSystem.CarControllerList.get(i).sensorSystem;
      //else if (s.clockWiseRotationFrameCounter > 500) {
      //  carSystem.CarControllerList.remove(carSystem.CarControllerList.get(i));
      //}
      if ((carSystem.CarControllerList.get(i).bil.pos.x > 500 ||carSystem.CarControllerList.get(i).bil.pos.x < 0) && totalFitness > 5000) {
        carSystem.CarControllerList.remove(carSystem.CarControllerList.get(i));
      } else if ((carSystem.CarControllerList.get(i).bil.pos.y > 600 ||carSystem.CarControllerList.get(i).bil.pos.y < 0) && totalFitness > 5000) {
        carSystem.CarControllerList.remove(carSystem.CarControllerList.get(i));
      } else if (s.whiteSensorFrameCount > 200 && carSystem.CarControllerList.size() > 5) {
        carSystem.CarControllerList.remove(carSystem.CarControllerList.get(i));
      }
      else if (s.clockWiseRotationFrameCounter < -200 && carSystem.CarControllerList.size() > 5){
          carSystem.CarControllerList.remove(carSystem.CarControllerList.get(i));
        }
    }
    if (frameCount%600==0) {
      for (int i = carSystem.CarControllerList.size()-1; i >= 0; i--) {
        SensorSystem s = carSystem.CarControllerList.get(i).sensorSystem;
        if (s.lapTimeInFrames == 10000 && carSystem.CarControllerList.size() > 1) {
          carSystem.CarControllerList.remove(carSystem.CarControllerList.get(i));
        }
        i = 0;
        calcAverage ();
        updateParameters();
        carSystem = new CarSystem(populationSize, LowerWeight, HigherWeight, LowerBias, HigherBias);
      }
    }
  }
}

void calcFitness() {
  totalFitness = 0;
  // Laver fitness funktion, der bestemmer hvor godt bilerne har klaret sig
  for (int i = carSystem.CarControllerList.size()-1; i >= 0; i--) {
    fitnessList[i] = (1/(carSystem.CarControllerList.get(i).sensorSystem.lapTimeInFrames +
      carSystem.CarControllerList.get(i).sensorSystem.clockWiseRotationFrameCounter +
      carSystem.CarControllerList.get(i).sensorSystem.whiteSensorFrameCount))*1000;

    if (carSystem.CarControllerList.get(i).sensorSystem.clockWiseRotationFrameCounter > 200) {
      fitnessList[i] = fitnessList[i] + 1000;
    }

    //Funktion der fjerner biler med en invalid fitnessværdi
    if (fitnessList[i] < 0) {
      fitnessList[i] = 0;
    }
    if (fitnessList[i] > 10000){
      fitnessList[i] = 10000;
    }
    totalFitness = totalFitness + fitnessList[i];
    println(fitnessList[i]);
  }
  println("totalFitness = ", totalFitness);
}


// Funktion der regner den gennemsnitlige weight og bias ud for hvert listeelement hos de tilbageværrende biler
void calcAverage() {
  calcFitness();
  for (int j = 7; j >= 0; j--) {
    weightAv[j] = 0;
    for (int i = carSystem.CarControllerList.size()-1; i >= 0; i--) {
      weightAv[j] = weightAv[j] + carSystem.CarControllerList.get(i).hjerne.weights[j]*fitnessList[i];
      if (j == 7) {
      }
    }
    weightAv[j] = weightAv[j]/totalFitness;
  }

  for (int i = carSystem.CarControllerList.size()-1; i >= 0; i--) {
    println("WhiteFrames ", i, carSystem.CarControllerList.get(i).sensorSystem.whiteSensorFrameCount);
    println("clockWiseRotationFrameCounter ", i, carSystem.CarControllerList.get(i).sensorSystem.clockWiseRotationFrameCounter);
    println("lapTimeInFrames ", i, carSystem.CarControllerList.get(i).sensorSystem.lapTimeInFrames);
  }

  for (int j = 2; j >= 0; j--) {
    biasAv[j] = 0;
    for (int i = carSystem.CarControllerList.size()-1; i >= 0; i--) {
      biasAv[j] = biasAv[j] + carSystem.CarControllerList.get(i).hjerne.biases[j]*fitnessList[i];
    }
    biasAv[j] = biasAv[j]/totalFitness;
  }
}

//Funktion der opdaterer værdiene for weight og bias 
void updateParameters() {
  if (totalFitness/fitnessList.length > 15) {
    varians = varians/2;

    println("varian ", varians);
  }
  for (int j = 7; j >= 0; j--) {
    LowerWeight[j] = weightAv[j] - varians;
    HigherWeight[j] = weightAv[j] + varians;

    println("weightAv = ", j, weightAv[j]);
  }
  for (int j = 2; j >= 0; j--) {
    LowerBias[j] = biasAv[j] -varians;
    HigherBias[j]= biasAv[j] + varians;
  }
}
