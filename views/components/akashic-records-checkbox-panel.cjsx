{React, ReactBootstrap, jQuery, config, __, CONST} = window
{Panel, Button, Col, Input, Grid, Row, ButtonGroup, DropdownButton,
  MenuItem, Table, OverlayTrigger, Popover, Collapse, Well} = ReactBootstrap
Divider = require './divider'
{openExternal} = require 'shell'

#i18n = require '../node_modules/i18n'
# {__} = i18n

dateToString = (date)->
  month = date.getMonth() + 1
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

AkashicRecordsCheckboxPanel = React.createClass
  handlePanelShow: ->
    show = not @props.show
    config.set "plugin.Akashic.#{@props.contentType}.checkboxPanelShow", show
    @props.setPanelVisibilitiy show

  handleClickCheckbox: (index) ->
    {tabVisibility} = @props
    tmp = Object.clone tabVisibility
    tmp[index] = not tmp[index]
    config.set "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify tmp
    @props.onCheckboxClick index, not tmp[index]
    
  handleClickConfigCheckbox: (index) ->
    @props.onConfigListSet index
  handleShowAmountSelect: (eventKey, selectedKey)->
    @props.onShowAmountSet selectedKey
  handleShowPageSelect: ()->
    val = parseInt @refs.pageSelected.getValue()
    if !val or val < 1
      val = 1
    @props.onShowAmountSet val

  render: ->
    <Grid>
      <Row>
        <Col xs={12}>
          <div onClick={@handlePanelShow}>
            <Divider text={__ "Filter"} icon={true} hr={true} show={@props.show}/>
          </div>
        </Col>
      </Row>
      <Collapse className='akashic-records-checkbox-panel' in={@props.show}>
        <div>
          <Row>
          {
            for checkedVal, index in @props.tableTab
              continue if !index
              <Col key={index} xs={2}>
                <Input type='checkbox' value={index} onChange={@handleClickCheckbox.bind(@, index)} checked={@props.tabVisibility[index]} style={verticalAlign: 'middle'} label={checkedVal} />
              </Col>
          }
          </Row>
          <hr/>
          <Row>
            <Col xs={2}>
              <ButtonGroup justified>
                <DropdownButton bsSize='xsmall' id="dropdown-showOption-selector" eventKey={4} title={__ "Newer %s", @props.showAmount}>
                  <MenuItem eventKey=10 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "10"}</MenuItem>
                  <MenuItem eventKey=20 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "20"}</MenuItem>
                  <MenuItem eventKey=50 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "50"}</MenuItem>
                  <MenuItem divider />
                  <MenuItem eventKey=999999 onSelect={@handleShowAmountSelect}>{__ "View All"}</MenuItem>
                </DropdownButton>
              </ButtonGroup>
            </Col>
            <Col xs={2} style={display: 'flex', textAlign: 'right'}>
              <div style={flex: 1, paddingRight: 10, paddingTop: 2}>
                {__ "Jump to"}
              </div>
              <div style={flex: 1, minWidth: 64}>
                <Input
                  type='number'
                  placeholder={"#{__ "Page %s", @props.activePage}"}
                  ref='pageSelected'
                  groupClassName='select-area'
                  onChange={@handleShowPageSelect}/>
              </div>
            </Col>
            <Col xs={5}>
            {
              for checkedVal, index in @props.configList
                continue if index is 3
                <Col key={index} xs={4}>
                  <Input type='checkbox' value={index} onChange={@handleClickConfigCheckbox.bind(@, index)} checked={@props.configListChecked[index]} style={verticalAlign: 'middle'} label={checkedVal} />
                </Col>
            }
            </Col>
            <Col xs={3}>
            {
              index = 3
              checkedVal = @props.configList[index]
              <Input type='checkbox' value={index} onChange={@handleClickConfigCheckbox.bind(@, index)} checked={@props.configListChecked[index]} style={verticalAlign: 'middle'} label={checkedVal} />
            }
            </Col>
          </Row>
        </div>
      </Collapse>
    </Grid>

module.exports = AkashicRecordsCheckboxPanel
