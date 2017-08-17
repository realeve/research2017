<template>
  <div class="wrapper">
    <div class="card" v-for="(question,i) of questionList" :key="i">
      <div class="content">
        <div class="weui-cells__title">{{i+1}}.{{question.title}}</div>
        <div class="weui-cells radio">
          <label for="" class="weui-cell weui-cell_radio weui-check__label" v-for="(answer,j) in researchData[i]" :key="j">
            <div class="weui-cell__bd">
              <p>{{answer.name}} ({{answer.value}}人)</p>
            </div>
            <div class="weui-cell__ft">
              <p>{{answer.percent}}%</p>
            </div>
            
            </label>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import {
    Group,
    Radio
  } from 'vux'

  import {
    dateFormat
  } from 'vux'

  import {
    mapState
  } from 'vuex'

  import questionList from '../assets/data/question.json';

  export default {
    components: {
      Group,
      Radio
    },
    data() {
      return {
        questionList,
        researchData: []
      }
    },
    computed: {
      ...mapState(['cdnUrl']),
      research() {

      }
    },
    methods: {
      init() {
        let params = {
          s: '/addon/Api/Api/getResearchCount'
        }
        this.$http.jsonp(this.cdnUrl, {
          params
        }).then(res => {
          var data = [];
          for (var i = 0; i < 18; i++) {
            data.push(res.data.filter(item => item.questionId == i))
          }
          this.researchData = data.map((question, i) => {
            var sum = 0;
            question.map(item => {
              sum += parseInt(item.nums);
            })
            return question.map(item => {
              return {
                name: item.answer,
                value: item.nums,
                percent: (parseInt(item.nums) * 100 / sum).toFixed(2)
              };
            })
          });
        });
        document.title = '结果统计';
      }
    },
    mounted() {
      this.init();
    }
  }

</script>

<style scoped lang="less">
  @import '~vux/src/styles/1px.less';
  @userSize: 60px;
  .wrapper {
    padding: 0 0 20px 0;
    background: #f5f5f5;
    border-radius: 4px;
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
    .weui-cell__ft{
      font-size:12pt;
    }
    .card {
      margin: 10px 5px;
    }
  }

</style>
