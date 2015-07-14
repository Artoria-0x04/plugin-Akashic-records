{React, ReactBootstrap, ROOT, FontAwesome} = window
{Grid, Row, Col, Input, Button, OverlayTrigger, Popover} = ReactBootstrap

fs = require 'fs-extra'
iconv = require 'iconv-lite'
jschardet = require 'jschardet'
path = require 'path-extra'

remote = require 'remote'
dialog = remote.require 'dialog'

duplicateRemoval = (arr) ->
  arr.sort (a, b)->
    if isNaN a[0]
      a[0] = (new Date(a[0])).getTime()
    if isNaN b[0]
      b[0] = (new Date(b[0])).getTime()
    b[0] - a[0]
  @lastTmp = 0
  arr.filter (log) =>
    flag = true
    tmpDate = new Date(log[0])
    tmp = "#{tmpDate.getFullYear()}/#{tmpDate.getMonth()}/#{tmpDate.getDate()}/#{tmpDate.getHours()}/#{tmpDate.getMinutes()}/#{tmpDate.getSeconds()}"
    if tmp is @lastTmp
      flag = false
    @lastTmp = tmp
    flag

toDateLabel = (datetime) ->
  date = new Date(datetime)
  month = date.getMonth()+1
  if month < 10
    month = "0#{month}"
  day = date.getDate()
  if day < 10
    day = "0#{day}"
  hour = date.getHours()
  if hour < 10
    hour = "0#{hour}"
  minute = date.getMinutes()
  if minute < 10
    minute = "0#{minute}"
  second = date.getSeconds()
  if second < 10
    second = "0#{second}"
  "#{date.getFullYear()}/#{month}/#{day} #{hour}:#{minute}:#{second}"

resolveFile = (fileContent, tableTab)->
  logs = fileContent.split "\n"
  logs[0] = logs[0].trim()
  switch logs[0]
    when "#{tableTab['attack'].slice(1).join(',')}"
      logType = "attack"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 12
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 12
    when "#{tableTab['mission'].slice(1).join(',')}"
      logType = "mission"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 11
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 11
    when "#{tableTab['createShip'].slice(1).join(',')}"
      logType = "createShip"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 12
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 12
    when "#{tableTab['createItem'].slice(1).join(',')}"
      logType = "createItem"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 10
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 10
    when "#{tableTab['resource'].slice(1).join(',')}"
      logType = "resource"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 9
          return []
        logItem[0] = (new Date(logItem[0])).getTime()
        logItem
      data = data.filter (log) ->
        log.length is 9
    when "No.,日付,海域,マス,出撃,ランク,敵艦隊,ドロップ艦種,ドロップ艦娘,大破艦,旗艦,旗艦(第二艦隊),MVP,MVP(第二艦隊)"
      logType = "attack"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 14
          return []
        retData = []
        retData.push (new Date(logItem[1].replace(/-/g, "/"))).getTime()
        tmpArray = logItem[3].match(/:\d+[-\d+]?/g)
        retData.push "#{logItem[2]}(#{tmpArray[0].substring(1)})"
        if logItem[4] is "ボス"
          tmp = "Boss点"
        else 
          tmp = "道中"
        retData.push "#{tmpArray[1].substring(1)}(#{tmp})"
        if logItem[4] is "出撃"
          tmp = "出击"
        else
          tmp = "进击"
        retData.push tmp
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[8]
        if logItem[9] is ""
          tmp = "无"
        else
          tmp = "有"
        retData.push tmp
        retData.push logItem[10]
        retData.push logItem[11]
        retData.push logItem[12]
        retData.push logItem[13]
        retData
      data = data.filter (log) ->
        log.length is 12
    when "No.,日付,結果,遠征,燃料,弾薬,鋼材,ボーキ,アイテム1,個数,アイテム2,個数"
      logType = "mission"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 12
          return []
        retData = []
        retData.push (new Date(logItem[1].replace(/-/g, "/"))).getTime()
        retData.push logItem[3]
        retData.push logItem[2]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push logItem[9]
        retData.push logItem[10]
        retData.push logItem[11]
        retData
      data = data.filter (log) ->
        log.length is 11
    when "No.,日付,種類,名前,艦種,燃料,弾薬,鋼材,ボーキ,開発資材,空きドック,秘書艦,司令部Lv"
      logType = "createShip"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 13
          return []
        retData = []
        retData.push (new Date(logItem[1].replace(/-/g, "/"))).getTime()
        if logItem[2] is "通常艦建造"
          tmp = "普通建造"
        else
          tmp = "大型建造"
        retData.push tmp
        retData.push logItem[4]
        retData.push logItem[3]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push logItem[9]
        retData.push logItem[10]
        retData.push logItem[11]
        retData.push logItem[12]
        retData
      data = data.filter (log) ->
        log.length is 12
    when "No.,日付,開発装備,種別,燃料,弾薬,鋼材,ボーキ,秘書艦,司令部Lv"
      logType = "createItem"
      data = logs.slice(1).map (logItem) ->
        logItem = logItem.split ','
        if logItem.length isnt 10
          return []
        retData = []
        retData.push (new Date(logItem[1].replace(/-/g, "/"))).getTime()
        if logItem[2] is "失敗"
          retData.push "失败"
          retData.push ""
          retData.push ""
        else 
          retData.push "成功"
          retData.push logItem[2]
          retData.push logItem[3]
        retData.push logItem[4]
        retData.push logItem[5]
        retData.push logItem[6]
        retData.push logItem[7]
        retData.push logItem[8]
        retData.push logItem[9]
        retData
      data = data.filter (log) ->
        log.length is 10
    # 需要去重
    # when "日付,直前のイベント,燃料,弾薬,鋼材,ボーキ,高速修復材,高速建造材,開発資材,改修資材"
    #   logType = "createItem"
    #   data = logs.slice(1).map (logItem) ->
    #     logItem = logItem.split ','
    #     if logItem.length isnt 10
    #       return []
    #     retData = []
    #     retData.push (new Date(logItem[0].replace(/-/g, "/"))).getTime()
    #     retData.push logItem[2]
    #     retData.push logItem[3]
    #     retData.push logItem[4]
    #     retData.push logItem[5]
    #     retData.push logItem[7]
    #     retData.push logItem[6]
    #     retData.push logItem[8]
    #     retData.push logItem[9]
    #     retData
    #   data = data.filter (log) ->
    #     log.length is 8
    else
      e = new Error()
      e.message = "不支持的编码或文件格式！"
      throw e
  ret = 
    logType: logType
    data: data
    message: ""

AttackLog = React.createClass
  getInitialState: ->
    typeChoosed: '出击'
  # componentWillMount: ->
  #   console.log "test"
  handleSetType: ->
    @setState
      typeChoosed: @refs.type.getValue()
  showMessage: (message)->
    dialog.showMessageBox
      type: 'info'
      buttons: ['确定']
      title: '提醒'
      message: message
  saveLogHandle: ->
    nickNameId = window._nickNameId
    if nickNameId and nickNameId isnt 0
      switch @state.typeChoosed
        when '出击'
          logType = 'attack'
          data = @props.attackData
        when '远征'
          logType = 'mission'
          data = @props.missionData
        when '建造'
          logType = 'createShip'
          data = @props.createShipData
        when '开发'
          logType = 'createItem'
          data = @props.createItemData
        when '资源'
          logType = 'resource'
          data = @props.resourceData
        else
          @showMessage '发生错误！请报告开发者'
          return
      if process.platform is 'win32'
        codeType = 'GB2312'
      else 
        codeType = 'utf8'
      filename = dialog.showSaveDialog
        title: "保存#{@state.typeChoosed}记录"
        defaultPath: "#{nickNameId}-#{logType}.csv"
      if filename?
        saveData = "#{@props.tableTab[logType].slice(1).join(',')}\n"
        for item in data
          saveData = "#{saveData}#{toDateLabel item[0]},#{item.slice(1).join(',')}\n"
        if codeType is 'GB2312'
          saveData = iconv.encode saveData, 'GB2312'
        fs.writeFile filename, saveData, (err)->
          if err
            console.log "err! Save data error"
    else
      @showMessage '未找到相应的提督！是不是还没登录？'
  importLogHandle: ->
    nickNameId = window._nickNameId
    if nickNameId and nickNameId isnt 0
      filename = dialog.showOpenDialog
        title: "导入#{@state.typeChoosed}记录"
        filters: [
          {
            name: "csv file"
            extensions: ['csv']
          }
        ]
        properties: ['openFile']
      if filename?[0]?
        try
          fs.accessSync(filename[0], fs.R_OK)
          fileContentBuffer = fs.readFileSync filename[0]
          codeType = jschardet.detect(fileContentBuffer).encoding
          switch codeType
            when 'UTF-8'
              fileContent = fileContentBuffer.toString()
            when 'GB2312', 'GB18030', 'GBK'
              fileContent = iconv.decode fileContentBuffer, 'GBK'
            when 'SHIFT_JIS'
              fileContent = iconv.decode fileContentBuffer, 'shiftjis'
            else
              fileContent = iconv.decode fileContentBuffer, 'shiftjis'
          {logType, data} = resolveFile fileContent, @props.tableTab
          switch logType
            when 'attack'
              hint = '出击'
              oldData = @props.attackData
            when 'mission'
              hint = '远征'
              oldData = @props.missionData
            when 'createShip'
              hint = '建造'
              oldData = @props.createShipData
            when 'createItem'
              hint = '开发'
              oldData = @props.createItemData
            when 'resource'
              hint = '资源'
              oldData = @props.resourceData
          oldData = duplicateRemoval oldData
          oldLength = oldData.length
          newData = oldData.concat data
          newData = duplicateRemoval newData
          newLength = newData.length
          fs.emptyDirSync path.join(APPDATA_PATH, 'akashic-records', "tmp")
          saveData = ""
          for item in newData
            saveData = "#{saveData}#{item.join(',')}\n"
          fs.writeFile path.join(APPDATA_PATH, 'akashic-records', "tmp", "data"), saveData
          fs.emptyDirSync path.join(APPDATA_PATH, 'akashic-records', nickNameId.toString(), logType.toLowerCase())
          fs.writeFile path.join(APPDATA_PATH, 'akashic-records', nickNameId.toString(), logType.toLowerCase(), "data"), saveData
          @showMessage "新导入#{newLength - oldLength}条#{hint}记录！重启后会刷新列表。"
        catch e
          @showMessage e.message
          throw e
    else
      @showMessage '请先登录再导入数据！'

      
    # console.log "import log"
    
  render: ->
    <div className="advancedmodule">
      <Grid>
        <Row className="title">
          <Col xs={12}>
            <span style={{fontSize: "24px"}}>数据导入导出</span>
            <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
              <Popover title='说明'>
                <h4>导出</h4>
                <ul>
                  <li>需选择导出类型</li>
                  <li>根据平台决定导出编码格式，win为GB2312，其他均为utf8</li>
                </ul>
                <h4>导入</h4>
                <ul>
                  <li>自动判断编码格式与类型</li>
                  <li>支持：
                    <ul>
                      <li>阿克夏记录</li>
                      <li>航海日誌 拡張版</li>
                    </ul>
                  </li>
                </ul>
              </Popover>
              }>
              <Button id='question-btn' bsStyle='default' bsSize='large' onClick={@props.switchShow}>
                <FontAwesome name='question-circle' className="fa-fw" />
              </Button>
            </OverlayTrigger>
          </Col>
        </Row>
        <Row>
          <Col xs={4}>
            <Input type="select" ref="type" value={@state.typeChoosed} onChange={@handleSetType}>
                <option key={0} value={'出击'}>出击</option>
                <option key={1} value={'远征'}>远征</option>
                <option key={2} value={'建造'}>建造</option>
                <option key={3} value={'开发'}>开发</option>
                <option key={4} value={'资源'}>资源</option>
            </Input>
          </Col>
          <Col xs={4}>
             <Button bsStyle='primary' style={width: '100%'} onClick={@saveLogHandle}>导出</Button>
          </Col>
          <Col xs={4}>
             <Button bsStyle='primary' style={width: '100%'} onClick={@importLogHandle}>导入</Button>
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <div>
              <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
                <Popover title=''>
                  <h4>统计页面部分</h4>
                  <ul>
                    <li>排序</li>
                    <li>高级搜索</li>
                  </ul>
                  <h4>其他功能</h4>
                  <ul>
                    <li>航海日志数据导入</li>
                    <li>允许离线查看</li>
                  </ul>
                </Popover>
                }>
                <Button bsStyle='default'>TODO list</Button>
              </OverlayTrigger>
              <h4>Bug汇报：https://github.com/yudachi/plugin-Akashic-records</h4>
            </div>
          </Col>
        </Row>
      </Grid>
    </div>


module.exports = AttackLog
