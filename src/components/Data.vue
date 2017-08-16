<template>
  <div class="wrapper">
    <div class="card weui-cells__title" v-for="(question,i) of questionList" :key="i">
    <div class="content">{{i+1}}.{{question.title}}</div>
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
        researchData:[]
      }
    },
    computed: {
      ...mapState(['cdnUrl']),
      research(){
        
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
          this.researchData = res.data;
        });        
        document.title = '现金使用情况问卷调查结果';
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
    .card{
      margin:10px 5px;
    }
  }

</style>
