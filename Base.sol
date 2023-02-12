// SPDX-License-Identifier: MIT
// solidityのコンパイラーバージョンを指定する
pragma solidity ^0.8.0;

// OwnableコントラクトとSafeMathライブラリを使用するためにインポートしている
import "./Ownable.sol";
import "./SafeMath.sol";

// contractには変数、マッピング、関数などを定義できる。Ownableコントラクトを継承してBaseという名のContractを作成している
contract Base is Ownable {

  // SafeMathライブラリーを使用して、オーバーフロー等の対策を行う
  using SafeMath for uint;

  // 新しいKittyがインスタンス化されたときにトランザクションログを出して外部からその内容を確認するために記述する。
  event NewKitty(string name, uint8 level);

  // 以下2つの変数を持つ、Kittyという構造体を定義
  struct Kitty {
    string name;
    // uint8は0-255を格納できる
    uint8 level;
  }

  // Kitty構造体の配列をkittiesという名前で定義
  // これ以下のcontract変数はイーサリアムブロックチェーンに保存される。更新にはガス代が必要になる。
  Kitty[] kitties;
  // ユーザのイーサリウムアドレス（キー）から、そのアドレスが所有しているkittiesのid（バリュー）を確認できるように定義
  // addressは20バイトの値であり、イーサリアムネットワーク上でのアカウントを意味する、公開鍵から作成される
  // publicに設定されている変数はこのcontract内外から値を参照することができる
  mapping (address => uint) public ownerToKitty;
  // イーサリウムアドレスがと、そのアドレスが所有するkittyの数のマッピング
  mapping (address => uint) public ownerKittyCount;

  // private変数は外部から参照できない
  uint private _numberOfKitty;

  // externalが設定された変数、関数はコントラクトの外部からアクセスできる。関数定義の引数名は_から始める慣習がある
  // 引数のmemoryは、_nameを関数処理完了までの間に一時的に（ブロックチェーン上ではなくて）メモリーに保存する設定
  // privateは、このコントラクトおよびこれを継承したコントラクトから関数を実行できる、この場合関数名は_から始める慣習がある
  // この関数はブロックチェーン上のデータを更新するのでガス代がかかる
  function _createKitty(string memory _name) private {
    // Kittyインスタンスのidはkitties配列の長さと同じ
    uint id = kitties.length;
    // Kittyインスタンスを作成してkitties配列にpushする、levelは最初は1固定
    kitties.push(Kitty(_name, 1));
    // ownerToKittyマッピングに新しいkitties idを追加, msg.senderは関数を実行したイーサリウムアドレスを指す
    ownerToKitty[msg.sender] = id;
    // ownerKittyCountを更新
    ownerKittyCount[msg.sender] = 1;
    // emitによって上で定義したeventを実際にトランザクションログに出力させる
    emit NewKitty(_name, 1);
  }

  // この関数はpublicなので、このコントラクト内外両方から実行することができる
  function createKitty(string memory _name) public {
    // kittyを所持していないアドレスのみが関数を実行できるようにrequireで制御している
    require(ownerKittyCount[msg.sender] == 0);
    _createKitty(_name);
  }
}
