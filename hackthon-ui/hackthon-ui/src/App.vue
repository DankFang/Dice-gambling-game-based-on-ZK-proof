<script setup>
// import HelloWorld from './components/HelloWorld.vue'
// import TheWelcome from './components/TheWelcome.vue''
import {ethers}  from  'ethers'
import { initialize } from "zokrates-js"
// import {fileSystem} from "browserify-fs"

import jsonData from '../verification_key.json'


console.log(typeof(jsonData) )
console.log(jsonData.pk)

        function sha256(b,d){
            initialize().then((zokratesProvider) => {
            const source2='import "hashes/sha256/512bitPacked" as sha256packed;def main(private field a, private field b, private field c, private field d)->field[2]{field[2] h = sha256packed([a, b, c, d]);return (h);}';
            const artifacts2 = zokratesProvider.compile(source2);
            const output2 = zokratesProvider.computeWitness(artifacts2, ["0",b,"0",d]);
            console.log(output2.output);
            return output2.output;
            });
            
        }

    async function login(){
            console.log("登陆")
       
            const provider = new ethers.BrowserProvider(window.ethereum)
            console.log(provider)
            const accounts = await  provider.send("eth_requestAccounts", []);
            const account = accounts[0]
            console.log(`钱包地址: ${account}`)

            //读取chainid
            const { chainId } = await provider.getNetwork()
            console.log(`chainid: ${chainId}`)

            // 读取ETH余额
            const signer =  await provider.getSigner()
            const balance = await provider.getBalance(signer.getAddress());
            console.log(`以太坊余额： ${ethers.formatUnits(balance)}`)

        }

    async function onRandom(){
            var res = []
            var num1 , num2;
            for (let i = 0; i < 6; i++) {
                res[i] = parseInt(Math.random()*6+1)
                console.log("生成随机数"+res[i]) 
                // more statements
            }
             num1 = res[0] + res[1] + res[2]
            num2 = res[3] + res[4] + res[5]
            res = sha256(num1.toString(),num2.toString());
            console.log(num1)
            console.log(num2)
            console.log(num1.toString() + num2.toString())
            console.log(typeof(num1.toString()))
            console.log(res)

            return res
    }

    // 弃牌
    function Dropp(){
        console.log("弃牌")

    }

    // 加注
    function Raise(){
        console.log("加注")
    }

    // ZK part 


    //      // 
        console.log('sadasdhuhuidqwhihudq')
        
        initialize().then((zokratesProvider) => {
            const source = 'import "hashes/sha256/512bitPacked" as sha256packed;  def main(private field a, private field b, private field c, private field d, public field[2] k)->bool {field[2] h = sha256packed([a, b, c, d]);return (h[0]==k[0]&&h[1]==k[1]); }';

              // compilation
        
            const artifacts = zokratesProvider.compile(source);

            console.log(artifacts)
          const data = JSON.stringify(artifacts);

            // write JSON string to a file
            fs.writeFile('zk.json', data, (err) => {
                if (err) {
                    throw err;
                }
                console.log("JSON data is saved.");
            });
            // computation
            const { witness, output } = zokratesProvider.computeWitness(artifacts, ["0","6","0","7",["52459441338105571243036069557385977283","233339224578782508577618226562668470987"]]);

            // // run setup
            var keypair;
            if (!keypair) {
                keypair = zokratesProvider.setup(artifacts.program);
                console.log("1111111111")
            }
            console.log(keypair)
                //const keypair = zokratesProvider.setup(artifacts.program);
            // const keypair=jsonData;
            console.log(keypair);
      //      const fs = require('fs');
            const kdata = JSON.stringify(keypair);

                        // // generate proof
            const proof = zokratesProvider.generateProof(
                artifacts.program,
                witness,
                keypair.pk
            );
            console.log(proof)

            // export solidity verifier
            const verifier = zokratesProvider.exportSolidityVerifier(keypair.vk);
            Scatterconsole.log("Proof is "+ verifier)
            // or verify off-chain
            //const isVerified = zokratesProvider.verify(keypair.vk, proof);
        });
         console.log("Proof is "+ zokratesProvider)


        

        function uphashchain(){
            var outp = sha256("6","7");
            console.log(outp)
            // console.log(outp[0]);
            // console.log(outp[1]); 
        }

        function pack(res){

        }


      

         function read(){
         
            fileSystem.readFile("./verification_key.json", (err, data) => {
            if(err) {
                console.log("File reading failed", err)
            return
            }
                 console.log("File data:", data)
                return data
            })
        }
        

        // tt =  read()

        uphashchain();
</script>

<template>
    
    
    <div id="app"  style="backgroup-color: blue"> 
        <div class=" ">
              <div class="container">
                <a class="navbar-brand" href="#"><img class="logo" src="./images/logo@2x.png" alt="">DiseGaming</a>
                <!-- <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent"
                    aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button> -->
                <div class="collapse navbar-collapse justify-content-end" id="navbarSupportedContent">
                    <button type="button"  style="margin: 10px auto;" data-toggle="modal"
                        data-target="#lottery">
                        <span class="lottery_btn">奖池</span>
                    </button>
                    <div class="src-occupy">
                        <a id="cpu" href="https://cpuemergency.com/" target="_blank"></a>
                        <a id="net" href="https://cpuemergency.com/" target="_blank"></a>
                    </div>
                    <ul class="navbar-nav mr-auto">
                        <li class="nav-item">
                            <a class="nav-link btnInvite" href="#" data-toggle="modal" data-target="#invite">邀请好友
                     
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link btnIntro" href="#" data-toggle="modal" data-target="#introduction">玩法介绍</a>
                        </li>
                   
                    </ul>
                    <div class="account">
                        <img src="./images/user_img@2x.png" alt="">
                       
                        <div class="nickname"></div>
                    </div>
                </div>
            </div>
        </div>
        
        
        
        
        <div>

             <div calss="BBX" >
                                <div>
                                    <button @click="login()"  id="Log " class="butt" >  登陆  </button>
                                </div>

                                <div>
                                    <button @click="onRandom()"  class="butt" >    摇摇  </button>
                                </div>  

                                <div>
                                    <button @click="Raise()"  class="butt" >    加注  </button>
                                </div>

                                <div>
                                    <button @click="Dropp()"  class="butt" >    弃牌  </button>
                                </div>
             </div>

        </div>
        
    </div> 
 

</template>

<style scoped>

#app {
    margin: 0px;
    padding: 0px; 
    width: 100%;
    height: 1000px;
    background-color: burlywood;

}


.BXX{

    margin-left: 300px;
    justify-content: center; 
}
.butt{
    margin-left: 600px;
    margin: 30px;
    background-color: blueviolet;
    color:black;
    height: 50px;
    width: 100px;
}
</style>
