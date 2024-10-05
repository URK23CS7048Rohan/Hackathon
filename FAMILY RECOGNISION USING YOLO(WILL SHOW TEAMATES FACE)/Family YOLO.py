from ultralytics import YOLO


model_path = r"C:\Users\rohan\OneDrive\Desktop\family.pt" 


model = YOLO(model_path)


model.info()


results = model.predict(1, show=True, save=True)
