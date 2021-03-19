# CO2 ダッシュボード

文化祭の会場の換気状況のダッシュボード

## Reauired

- nim

## Usage

1. configファイルの設定  
  `cp ./sec/config.nim.example ./src/config.nim`
2. karaxのインストール  
  `nimble install karax`  
  `$HOME/.nimble/bin`をPATHに設定する
3. ビルド  
  `karun ./src/co2_dashboard`
4. ヘッダ  
  `head`タグに下記のものを記述する
  ```html
    <script src="your fontawesome link" crossorigin="anonymous"></script>
  <link rel="stylesheet" href="./style.css" type="text/css">
  ```
