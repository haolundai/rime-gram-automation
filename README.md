# rime-gram-automation

在 WSL Ubuntu 上，盡量用一套固定流程生成 `zh-hant.gram`。

## 1) 設定（把路徑改成你自己的）
```
cp ./rime_gram_config.example.sh ~/.rime_gram_config.sh
nano ~/.rime_gram_config.sh
```

## 2) 一次性安裝依賴
```
bash ./scripts/bootstrap_wsl.sh
```

## 3) 一鍵執行
```
bash ./run.sh
```

