<template>
  <div class="head">

    <img class="logo" src="http://cbpm.sinaapp.com/cdn/201708/static/img/bg.jpg">
    <div class="title">
      现金使用情况调查问卷
    </div>
  </div>
</template>
<style scoped lang="less">
.head {
  text-align: center;
  width: 100%;
  padding: 0;
  margin: 0;
  .title {
    font-weight: 100;
    font-size: 16pt;
    margin-top: -50px;
    color: #fff;
    margin-bottom: 0px;
  }
  .logo {
    width: 100%;
    height: 100%;
  }
}
</style>
<script>
import { mapState } from "vuex";
export default {
  computed: {
    ...mapState(["userInfo"])
  }
};
</script>

