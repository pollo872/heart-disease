class SubmitAssessmentModel {
  double? bmi;
  String? age;
  String? sex;
  String? race;
  int? height;
  int? weight;

  String? smoking;
  String? alcohol;
  String? physicalActivity;
  String? difficultyWalking;
  String? diabetic;
  String? generalHealth ;
  String? asthma;
  String? stroke;
  String? kidneyDisease;
  String? skinCancer;
  int? physicalHealthDays;
  int? mentalHealthDays ;
  int? sleepTime ;

  

  Map<String, dynamic> toJson() {
    return {
      "BMI": bmi,
      "AgeCategory": age,
      "Sex": sex,
      "Race": race,
      "height": height,
      "weight": weight,
      "Smoking": smoking,
      "AlcoholDrinking": alcohol,
      "PhysicalActivity": physicalActivity,
      "DiffWalking": difficultyWalking,
      "Diabetic": diabetic,
      "GenHealth": generalHealth ,
      "Asthma": asthma,
      "Stroke": stroke,
      "KidneyDisease": kidneyDisease,
      "SkinCancer": skinCancer,
      "PhysicalHealth": physicalHealthDays,
      "MentalHealth": mentalHealthDays ,
      "SleepTime": sleepTime ,

      
    };
  }
}