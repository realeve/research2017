<template>
  <div class="wrapper">
    <div class="tip">
      感谢您的参与本次共收到问卷{{paper}}份，本数据统计延迟更新1分钟。
    </div>
    <div class="card" v-for="(question,i) of questionList" :key="i">
      <div class="content">
        <div class="weui-cells__title">{{i+1}}.{{question.title.split('（ ')[0]}}</div>
        <!-- .replace('请问您','你') -->
        <div class="chart" :id="'chart'+i"></div>
      </div>
    </div>
  </div>
</template>

<script>
import { Group, Radio } from "vux";

import { dateFormat } from "vux";

import { mapState } from "vuex";

import questionList from "../assets/data/reject.json";
import echarts from "echarts";

export default {
  components: {
    Group,
    Radio
  },
  data() {
    return {
      questionList,
      researchData: [],
      paper: ""
    };
  },
  computed: {
    ...mapState(["cdnUrl"])
  },
  watch: {
    researchData(data) {
      data.forEach((item, idx) => {
        this.initChart(item, idx);
      });
      let sum = this.researchData[0].reduce(
        (sum, item) => sum + parseInt(item.value),
        0
      );
      this.paper = sum;
    }
  },
  methods: {
    init() {
      let params = {
        s: "/addon/Api/Api/getVoteCountByLog",
        sid: this.$store.state.sport.id
      };
      this.$http
        .jsonp(this.cdnUrl, {
          params
        })
        .then(res => {
          // var data = [];
          // for (var i = 0; i < 18; i++) {
          //   data.push(res.data.filter(item => item.questionId == i));
          // }
          // this.researchData = data.map(question => {
          //   return question.map(item => {
          //     return {
          //       name: item.answer,
          //       value: item.nums
          //     };
          //   });
          // });
          this.researchData = [res.data];
        });
      document.title = "结果统计";
    },
    getOption(data) {
      return {
        tooltip: {
          trigger: "item",
          formatter: "{a} <br/>{b}: {c} ({d}%)"
        },
        color: [
          "#61A5E8",
          "#7ECF51",
          "#E16757",
          "#9570E5",
          "#605FF0",
          "#85ca36",
          "#1c9925",
          "#0d8b5f",
          "#0f9cd3",
          "#2f7e9b",
          "#2f677d",
          "#9b7fed",
          "#7453d6",
          "#3b1d98",
          "#27abb1",
          "#017377",
          "#015f63",
          "#b86868",
          "#5669b7",
          "#e5aab4",
          "#60b65f",
          "#98d2b2",
          "#c9c8bc",
          "#45c3dc",
          "#e17979",
          "#5baa5a",
          "#eaccc2",
          "#ffaa74"
        ],
        series: [
          {
            type: "pie",
            radius: ["40%", "55%"],
            startAngle: 45,
            data,
            label: {
              normal: {
                formatter: function(param) {
                  return (
                    param.name +
                    "\n(" +
                    param.percent.toFixed(2) +
                    "%)\n" +
                    param.value +
                    "人"
                  );
                }
              }
            }
          }
        ]
      };
    },
    initChart(data, idx) {
      let option = this.getOption(data);
      let dom = document.querySelector("#chart" + idx);
      let chart = echarts.init(dom);
      chart.setOption(option);
    }
  },
  mounted() {
    this.init();
  }
};
</script>

<style scoped lang="less">
@import "~vux/src/styles/1px.less";
@userSize: 60px;
.wrapper {
  padding: 0 0 20px 0;
  background: #f5f5f5;
  border-radius: 4px;
  .thin {
    font-weight: 100;
  }
  .chart {
    width: 100%;
    height: 250px;
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
  .card {
    margin: 10px 5px;
  }
  .tip {
    margin-top: 20px;
    padding: 10px;
    color: #555;
    background: #fff;
  }
}
</style>
