// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

// forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/API_KEY --fork-block-number 31215311 -vv

interface IStaking {
    function earned(address account) external returns (uint256);
    function periodFinish() external returns (uint256);
    function stake(uint256 amount) external;
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

contract ContractTest is Test {
    IStaking private constant STAKING = IStaking(0xbaef1B35798bA6C2FA95d340dc6aAf284BBe2EEe);
    IERC20 private constant QUICK = IERC20(0xB5C064F955D8e7F38fE0460C556a72987494eE17);

    function setUp() public {
        QUICK.approve(address(STAKING), type(uint256).max);
    }
    
    function stake() private {
        deal(address(QUICK), address(this), 1);
        STAKING.stake(1);
    }

    function stakePeriodically() private {
        uint256 n = 1;
        uint256 interval = (STAKING.periodFinish() - block.timestamp)/n;

        console.log("num stakes", n);
        console.log("interval (minutes)", interval/60);

        for (uint256 i = 0; i < n; i++) {
            stake();
            vm.warp(block.timestamp + interval);
        }
    }

    function calculateTotalEarned() private returns (uint256 total) {
        for (uint256 i = 0; i < accounts.length; i++) {
            total += STAKING.earned(accounts[i]);
            if (STAKING.earned(accounts[i]) > 0) {
                console.log(accounts[i], STAKING.earned(accounts[i]));
            }
        }
    }

    function testExample() public {
        uint256 earnedStart = calculateTotalEarned();

        stakePeriodically();

        vm.warp(STAKING.periodFinish());

        uint256 earnedEnd = calculateTotalEarned();
        console.log("earned at start", earnedStart);
        console.log("total earned at end", earnedEnd);
        console.log("diff", earnedEnd - earnedStart);
    }

    address[] private accounts = [
        address(this),
        0xB7a4333eD9b4FF84E5a81B76Fa1e16e53DF5f6C2,
        0x5e5b0A2c56A4C6139F772946d68cDf3AAc06E713,
        0xC35Bd8e35D5C866F90bD8Db563680712560A9765,
        0x2913031eb8b294156E0cb48b147F1f0B7A78d2A2,
        0x93A79ae91740c54B1221BDB2B44bE1CB5eB8fF52,
        0x6D807e6564d90de613E2280A3e943c32A57E18d6,
        0x959fFef805eAF0ca5ed616751d2293177f458F0e,
        0xf32f5945edCA05748233fdea8460EcEE16c3A367,
        0x8fB20c72139B2A971Ab814503D61111349f8Cc78,
        0x1Fc1e266758D5a51b301A1bc0B8615AAA979EFdf,
        0x316720A5d402110978851Fcb02cF216eDA73b2FA,
        0x3574FB0aF6e8750f8778EEE060559301AA293e07,
        0x4c365470493bD2A93Ebe1761179B29a1AB4e5fFc,
        0xc704598924a69529996fbdb6B0E24Ea6E6a6ccB5,
        0x78867E046Fd2ccb6498Ab8FF619913458d4F3995,
        0x12489C7ED4a3958180fd2B3F635C5eBDD878fE77,
        0x976eE43868242346A133951dBE829fE7F5f0ee6c,
        0x0abAf95A8FEbc103ed55c70Ce01fad126Ba4e03a,
        0xe5a64a863C5F48B283F5b0aC1d17809bf92656BC,
        0x4b445dE599503C1A64174B433AC7DC57658211E4,
        0x447aD03908D965aAdaFe007D9E383eCfD03306C8,
        0x62A2e88e0E35b7D694d03adA42122c1E9Ad7E1B5,
        0x256eF37b6C72c21CCbf7c7A85fE8368C4Dc472fF,
        0xD43a5f89CcD38E7bFdC409069bdC2a7A7b4BF145,
        0x8f9D959Adde5f1E9A7166EEec87ACD43cC7529f9,
        0x684dea9b2776905DFB0515E237bCa1219F2B853d,
        0xad94490585B60EF1C3552932f74414368653FAfA,
        0x6c1e4d01003f6eF933baafEA7365b7924b8b1bBc,
        0x3F13c8EcDd224197EA42Fa7722B765D873190f4e,
        0x30a40961a176E74Ff72386fBcE5434E755eEaaaF,
        0x33833541a74Ef975D6E5eddEb636201694E32DA9,
        0x86EbF74Cb2c9Dea170d2ce937Db61b22712EB5EA,
        0x5ACA0AcefC9fF1190b929cEb2070440134009052,
        0xe610017d610E00026A0E5fA74a28D20872EA24F7,
        0x747276019e3340104C96397bF6537aD01F93D7df,
        0xfDdA39e1d78E11470d1329937cFb20Df6f93d3F1,
        0x87EAA287112aEcC274c31Be1b933B71cfFD65b5B,
        0x5eE89b71f055102FbE82A993c4364953499f2bC4,
        0xFaffa6198f78206BA54fBAa26f7D6D72adbDB9C9,
        0x860C79b80a6bDFF8de4fb56b19b12DDE0de60f93,
        0xFf1Df715F24cc6C97019CCBc83Ad099dDF790b05,
        0x29FACEEc357d9747Fdc909908332007868cb0380,
        0x93beCA36d5bcDC7Be0F9cA38b1b5F5F5292aa859,
        0x486EF3e10D515d9fa386dD99ec8c2929533D5417,
        0xDE79fA44e6A37F437b2DC74E81e3958ABe9f000F,
        0x12d0A46bd26Fae22d30F2780210Ff1aC0aD41187,
        0x7E81584dB1617Cc2CcBD44646720B7844ffE2D24,
        0x964D66C23fE9f98B1678a683aafEef86AF4ECa52,
        0xfF24b0dB49836d362E97d34657EA749F56090C8A,
        0x23684b2E8108Bc6b54b5Fe51719450796B2A1989,
        0x3952b693c0D21039cDcCEe6d8efbc74B633D67F7,
        0xF0e130F600f03A6A369e89E224541dc813e97B07,
        0xb7439767143691fdF106B99771E0Fe4269788352,
        0x2ee05Fad3b206a232E985acBda949B215C67F00e,
        0x9297ee58432312285fC5dEb245f6F19f9a93230E,
        0x89C453Dc58970285E46FCF5fC2F73053FD0A5945,
        0x153696504C43e1F5001A65A1d235D02BdfBc6A36,
        0xd9DFEb3028d10E03785742c8912A6fA6E872CDD7,
        0x95689DfA2070d38d15e43878062Dc0fCeaA89B75,
        0x4A67Bb14cd5A9DE2292D5A1aDD3f953796b59570,
        0xA0e3C3d6fC0CF28b55518aBf98372B4E120Dde8b,
        0x3309Cc354D6F7dAA5D13bE1B0Fdee8c423e5C8C1,
        0x2D36aa86282c415885519C76F84c553A38A4E204,
        0x2eca0BE455683Dc60406C1e1782a20692a14628C,
        0x44aA331c17f0c5084744D3D7b73724651545aC9F,
        0x2b44d9764fbbd2B07fbc48212aee4Da331806062,
        0xffff100B0017aCED8E01b8eB0454FE09c43364b9,
        0xC6be75Aa7098E8bb505a8346812A6811a07Ac5Ce,
        0xc6654898d96e97199A8d14E534fe92dd6B2674BD,
        0xC2640aEae697b174C895455aB6aD6905166d732D,
        0xCF2c5103A241397A6D1989e347C80d7945120329,
        0xBf058529c90b96c0Fa38F486Fa80363A46c3a042,
        0x63eeccaC59E36c6588EB066cCB5246cf1668f47F,
        0xE8A91588Bd64787a3670443C5c753E8AD9a60bCd,
        0x1542CCe4016b32e481502db0772850180aB9f041,
        0x4ceAb724f0103C4ccc7aA1a324efBa35FE3D0DC0,
        0xb8cEA967F39A39521585262DE95655A451FD38f7,
        0xf70751097082CA02D58cFfC8bd1D0EE062E56967,
        0x2e7D4DA81791E6ec40b86c1DD937929293504009,
        0x78fCEadB4356137bdB84417439C6213D78323d16,
        0x142e6EE40bd42643aA4D3F7A0ae066997F902788,
        0xDC076286a48020dcFBbBb45207E8c227AF51e9dF,
        0x9D1F853f70819e7328a104ae4551B1E78F57c806
    ];
}
