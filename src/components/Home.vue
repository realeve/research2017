<template>
  <div class="wrapper">
    <div class="welcome">
      <!-- <img class="user" :src="userInfo.headimgurl"> -->
      <p class="txt">{{userInfo.nickname}}您好,感谢参加本次调查问卷活动,本问卷数据我们只用于对现金使用情况研究,不作它用。<br>
        <span style="font-weight:bold;">填写问卷前请先选择您所在的省/市/区方便数据统计，</span>数据提交后系统会自动抽奖，请您认真作答，感谢您的参与。
      </p>
    </div>

    <group>
      <x-address title="您所在的省/市" raw-value v-model="addressArr" :list="addressData" inline-desc="点击设置地址"></x-address>
    </group>
    <div v-show="address.length>0" v-for="(question,i) of questionList" :key="question.title">
      <p v-if="i==12" class="queTip">第5题您的职业选【商户或零售经营者】的答卷者，继续回答以下问题。选择其他选项的答题者请勿填。</p>
      <checklist v-if="question.multiply" label-position="left" :title="`${i+1}.${question.title}`" required :options="question.option" v-model="answerList[i]" @on-change="change"></checklist>
      <group v-else class="content" :title="`${i+1}.${question.title}`">
        <radio :options="question.option" v-model="answerList[i]" @on-change="change"></radio>
      </group>
    </div>
    <div v-show="address.length>0" class="submit">
      <x-button :disabled="!isCompleted" type="primary" @click.native="submit">提交</x-button>
    </div>
    <toast v-model="toast.show">{{ toast.msg }}</toast>
  </div>
</template>

<script>
import {
  Toast,
  Group,
  Radio,
  Checklist,
  XButton,
  XAddress,
  ChinaAddressV3Data,
  Value2nameFilter as value2name
} from "vux";

import { dateFormat } from "vux";

import { mapState } from "vuex";
import md5 from "md5";

// import questionList from "../assets/data/question.json";
import questionList from "../assets/data/reject.json";

export default {
  components: {
    Toast,
    Group,
    Radio,
    Checklist,
    XButton,
    XAddress
  },
  data() {
    return {
      toast: {
        show: false,
        msg: ""
      },
      time: new Date().getTime(),
      questionList, //: questionList.slice(0, 12),
      answerList: [],
      isCompleted: false,
      addressArr: [],
      addressData: ChinaAddressV3Data
    };
  },
  computed: {
    ...mapState(["userInfo", "cdnUrl", "sport"]),
    url() {
      return window.location.href.split("#")[0];
    },
    openid() {
      return this.userInfo.openid;
    },
    usertype() {
      return this.answerList[4] == "商户或零售经营者" ? 1 : 0;
    },
    address() {
      return value2name(this.addressArr, ChinaAddressV3Data);
    }
  },
  watch: {
    answerList(val) {
      this.getCompleteStatus();
    }
  },
  methods: {
    getSignature() {
      this.time = new Date().getTime();
      this.signature = md5(
        btoa(
          this.sport.salt + this.time + this.openid + this.openid.toUpperCase()
        )
      );
    },
    getCompleteStatus() {
      // if (this.answerList[4] == "商户或零售经营者") {
      //   this.questionList = questionList;
      // } else {
      //   this.questionList = questionList.slice(0, 12);
      // }

      let flag = true;
      // this.answerList.length
      for (let i = 0; flag && i < 12; i++) {
        let item = this.answerList[i];
        if (item == "") {
          flag = false;
        }
      }
      this.isCompleted = flag;
    },
    change() {
      // console.log(this.answerList);
    },
    getSubmitData() {
      this.getSignature();
      let address = this.address.split(" ");
      let [province, city, area_name] = address;
      window.localStorage.setItem("user_address", JSON.stringify(address));

      return {
        s: "/addon/Api/Api/addAnswerInfo",
        sid: this.sport.id,
        timestamp: this.time,
        signature: this.signature,
        addstr: this.convertAnswers(), //this.answerList.join(","),
        openid: this.userInfo.openid,
        nickname:
          typeof this.userInfo.nickname == "undefined"
            ? "未知"
            : this.userInfo.nickname,
        sex: this.userInfo.sex,
        city, //: this.userInfo.city,
        province, //: this.userInfo.province,
        area_name,
        country: this.userInfo.country,
        headimgurl: this.userInfo.headimgurl,
        usertype: this.usertype, // this.questionList.length == 12 ? "0" : 1

        // 是否为无效问卷
        invalid:
          this.usertype == 0 &&
          (this.answerList[12].length > 0 || this.answerList[13].length > 0)
      };
    },
    convertAnswers() {
      let answers = [];
      this.answerList.map((item, idx) => {
        let question = questionList[idx].option;
        let curAnswer = [];
        question.forEach((answer, i) => {
          if (item.includes(answer)) {
            curAnswer.push(i);
          }
        });
        answers.push(curAnswer.join(","));
      });

      // 将所有题目选项答案连接
      return answers.map(item => `'${item}'`).join(",");
    },
    submit() {
      let params = this.getSubmitData();
      // console.log(params);
      // return;
      // params.s = "/addon/Api/Api/setResearch";
      this.$http
        .jsonp(this.cdnUrl, {
          params
        })
        .then(res => {
          this.toast.show = true;
          this.toast.msg = res.data.msg;
          if (res.data.status == 1) {
            // 进入抽奖页面
            this.$router.push("address");
          }
        })
        .catch(e => {
          console.log(e);
        });
    },
    auth() {
      if (
        location.href.indexOf("from=singlemessage") > 0 ||
        location.href.indexOf("from=timeline") > 0 ||
        location.href.indexOf("from=groupmessage") > 0
      ) {
        this.$router.push("/follow");
        return false;
      }
      return true;
    },
    init() {
      let passed = this.auth();
      if (!passed || this.userInfo.openid == null) {
        return;
      }

      let params = {
        // s: "/addon/Api/Api/isSetUserInfo",
        s: "/addon/Api/Api/getResearchStatus",
        openid: this.openid,
        sid: this.sport.id
      };
      this.$http
        .jsonp(this.cdnUrl, {
          params
        })
        .then(res => {
          // if (res.data.status > 1) {
          //   // 进入抽奖页面
          //   this.$router.push("address");
          // } else {
          //   document.title = "现金使用情况调查问卷";
          //   this.answerList = this.questionList.map(
          //     item => (item.multiply ? [] : "")
          //   );
          // }

          if (res.data.length > 0) {
            this.addressArr = [
              res.data[0].province,
              res.data[0].city,
              res.data[0].area_name
            ];
            // 进入抽奖页面
            this.$router.push("address");
          } else {
            document.title = "现金使用情况调查问卷";
            this.answerList = this.questionList.map(
              item => (item.multiply ? [] : "")
            );
          }
        });
    }
  },
  mounted() {
    if (this.auth()) {
      this.init();
    }
  }
};
</script>

<style scoped lang="less">
@import "~vux/src/styles/1px.less";
@userSize: 60px;
.wrapper {
  padding: 0 0 20px 0;
  .thin {
    font-weight: 100;
  }
  .title {
    font-size: 18pt;
    .thin;
    text-align: center;
    line-height: 60px; // border-bottom: 1px solid #ccc;
  }
  .content {
    margin: 20px 0;
    padding: 10px;
    color: #444;
    background: #fff;
  }
  .submit {
    margin: 20px;
  }
  .welcome {
    padding: 30px 5px 0 5px;
    display: flex;
    flex-direction: row;
    .user {
      width: @userSize;
      height: @userSize;
      border-radius: 50%;
    }
    .txt {
      // padding-left: 20px;
      font-size: 11pt;
      color: #555;
    }
  }
  .queTip {
    color: #e55;
    font-weight: bold;
    padding: 35px 15px 10px 18px;
    font-size: 15pt;
  }
}
</style>