<html>
<head>
	<title>EC2 Signal</title>
        <link href="{{URL}}static/bootstrap.min.css" rel="stylesheet">
        <link href="{{URL}}static/customed.css" rel="stylesheet">
</head>
<body>

<div class="container">
<div class="page-header">
	<h1>EC2 Signal</h1>
</div>

<div class="page-header">
	<h4>Instance Status</h4>
</div>
<div class="contents">
<table class="table table-bordered">
	<tr><th>Name</th><th>Instance ID</th><th>Status</th></tr>
% i = 0;
% for id in instanceId:
	% name = instanceName[i]
	% status = instanceState[i]
		<tr id="item" name="{{name}}" instanceid="{{id}}" status="{{status}}" data-toggle='modal' href="#myModal">
		<td>{{name}}</td>
		<td>{{id}}</td>
	% if (status == "stopped"):
		<td><img src='{{URL}}static/signal-red.png' class="signal"/>{{status}}</td>
	% elif(status == "running"):
		<td><img src='{{URL}}static/signal-blue.png' class="signal">{{status}}</td>
	% else:
		<td><img src='{{URL}}static/signal-yellow.png' class="signal"/>{{status}}</td>
	% end
	</tr>
	% i = i+1
% end
</table>
</div>
</div>

<!-- Modal -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h4 class="modal-title" id="myModalLabel">確認</h4>
      </div>
      <div class="modal-body">
	Processing now. <br>Reload browser please.
      </div>
      <div class="modal-footer">
	<form action="">
        <button type="button" class="btn btn-default" data-dismiss="modal">No</button>
        <button type="submit" class="btn btn-primary" name="id" value="">Yes</button>
	</form>
      </div>
    </div><!-- /.modal-content -->
  </div><!-- /.modal-dialog -->
</div><!-- /.modal -->


<script src="https://code.jquery.com/jquery.js"></script>
<script src="{{URL}}static/bootstrap.min.js"></script>
<script language="javascript" type="text/javascript">
$(function(){
	$("tr[id = 'item']").mouseover(function(){
		$(this).addClass("success");
	}).mouseout(function(){
		$(this).removeClass("success");
	}).click(function(){
		var con = $(this).attr("name");
		var currentStatus = $(this).attr("status");

		if (currentStatus == "running"){
			$("div.modal-footer").children("form[action]").attr("action", "{{URL}}doStop");
			$("[class = modal-body]").text(con + "is RUNNING.");
			$(".modal-body").append("<br>Stop Server?");
			$("button[type = submit]").text("STOP");
		}else if (currentStatus == "stopped"){
			$("div.modal-footer").children("form[action]").attr("action", "{{URL}}doStart");
			$("[class = modal-body]").text(con + "is STOPPING.");
			$(".modal-body").append("<br>Start Server?");
			$("button[type = submit]").text("START");
		} else{
			$("div.modal-footer").children("form[action]").attr("action", "{{URL}}redirectIndex");
			$("[class = modal-body]").text("Processing now.");
			$(".modal-body").append("<br>Reload browser please.");
			$("button[type = submit]").text("RELOAD");
		}

		$("[type = submit]").attr("value", $(this).attr("instanceid"));
	})
});
</script>
</body>
</html>
