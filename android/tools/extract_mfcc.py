# android/tools/extract_mfcc.py
import librosa
import json
import sys

file_path = sys.argv[1] if len(sys.argv) > 1 else "verify_voice.wav"
y, sr = librosa.load(file_path, sr=16000)

mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
embedding = mfcc.mean(axis=1)

out_path = file_path + ".json"
with open(out_path, 'w') as f:
    json.dump(embedding.tolist(), f)

print(f"✅ تم حفظ الـ embedding في: {out_path}")
