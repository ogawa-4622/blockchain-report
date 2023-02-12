// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Baseコントラクトを継承するためにBase.solをimportする
import "./Base.sol";

// Baseコントラクトを継承してHelperコントラクトを定義
contract Helper is Base {

  using SafeMath8 for uint8;

  // 1 ether = 10^18 wei に変換される、publicなので外部から確認可能
  uint public levelUpFee = 0.001 ether;

  // スマートコントラクトはデプロイ後は修正できない。後で変更する必要がありそうな変数は予め関数で変更可能にしておく
  // levelUpFeeを更新するための関数、onlyOwnerというmodifierによってコントラクトをデプロイしたのと同じアドレスからしか利用できない
  // externalが設定された変数、関数はコントラクトの外部からのみアクセスできる。
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  // viewをつけた関数はブロックチェーン上のデータを読み取るだけで更新しないのでガス代がかからない
  // returnするデータ型を指定している、変数はpublicなのでこの関数なしでも確認することは可能
  function getLevelUpFee() external view returns (uint) {
    return levelUpFee;
  }

  // payableをつけた関数は実行時にethを受け取ることができる、ethはこのコントラクトのアドレス(デプロイ時に確定)に保存される
  // この関数はlevelUpFeeに指定されているethを支払うことで指定したIDのKittyインスタンスをレベルアップさせる
  function levelUp(uint _kittyId) external payable {
    // msg.valueはこの関数を実行するときに指定したethの量、これがlevelUpFeeと以上であることを条件にしている
    require(msg.value >= levelUpFee);
    // 送信したeth割るlevelUpFee（小数点以下切り捨て）分レベルアップする
    uint8 up = uint8(msg.value / levelUpFee);
    kitties[_kittyId].level = kitties[_kittyId].level.add(up);
  }

  // このスマートコントラクトアドレスにあるethをコントラクトをデプロイしたアドレスに移動させる関数
  // コントラクトのオーナー以外は使用できない
  function withdraw() external onlyOwner {
    // payable設定されているaddressにのみsend, transferが使用可能
    address payable _owner = payable(owner());
    // このコントラクトアドレスにある残高をすべてオーナーのアドレスに移動する
    _owner.transfer(address(this).balance);
  }
}
