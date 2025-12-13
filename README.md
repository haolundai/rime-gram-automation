# rime-gram-automation

在 WSL Ubuntu 上，盡量用一套固定流程生成 `zh-hant.gram`。

## 1) git（in WSL）
```
cd ~
git clone https://github.com/haolundai/rime-gram-automation.git
cd rime-gram-automation
```

## 2) 設定（把路徑改成你自己的）
```
cp ./rime_gram_config.example.sh ~/.rime_gram_config.sh
nano ~/.rime_gram_config.sh
```

## 3) 一次性安裝依賴
```
bash ./scripts/bootstrap_wsl.sh
```

## 4) 一鍵執行
```
bash ./run.sh
```



# test 1-1) 跑乾淨驗證
bash scripts/clean_verify.sh
