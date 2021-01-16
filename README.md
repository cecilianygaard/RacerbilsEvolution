# RacerbilsEvolution

Funktionen for weight og bias er lavet om til at være seperate variable (HigherWeight, LowerWeight, HeigherBias, LowerBias). Dette er gjort for at programmet kan gå ind og ændre på og aflæse disse værdier individuelt. På denne måde kan disse ændres hver gang der laves en ny population.

Mens programmet kørrer sorteres de dårlige biler fra. Bilernes effektivitet bestemmes ud fra en kombination af de funktioner der allerede var indbygget i koden (clockWiseRotationFrameCounter, whiteSensorFramCount og lapTimeInFrames), samt en fitness funktion, der er justeret eksperimentielt. Desuden frasorteres biler der bevæger sig uden for det tegnede vindue (0,0,1000,1000 - bestemt af pos.x og pos.y). Dog bevares et minimalt antal af biler uanset hvadd for at undgå en tom liste.

Når en ny population laves vægtes fitness-værdiene for alle de resterende biler, og der laves ud fra dette et gennemsnit for weight og bias (weightAv og biasAv). Dem med højere fitness-værdi trækker således mere i gennemsnittet. Hvis fitness-værdien bliver lavere end 0, sættes den til at være 0, og hvis den er over 10 000, sættes den til at være 10 000. Dette er for at undgå fejl i gennemsnittet.

Variansen for weight og bias reduceres når den gennemsnitlige fitness bliver høj nok. Derfor bliver bilernes weight og bias mere ens når de bliver bedre.

På grund af disse ting udvikler bilerne sig til at ligge på banen.
