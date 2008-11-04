﻿<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
site_title = "用户列表"
Select Case Request.QueryString("action")
	Case "hits"
		hits()
	Case Else
		header()
		menu()
		main()
		footer()
End Select

sub main()
'action=user
dim user_id,cmp_name,order,by
user_id=Checkstr(Request.QueryString("user_id"))
cmp_name=Checkstr(Request.QueryString("cmp_name"))
order=Checkstr(Request.QueryString("order"))
by=Checkstr(Request.QueryString("by"))
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <td><span style="float:left;">
      <form onSubmit="return searcher();">
        播放器名
        <input type="text" name="cmp_name" id="cmp_name" value="<%=cmp_name%>" />
        <input type="submit" name="search" id="search" value="搜索" />
      </form>
      </span></td>
  </tr>
  <tr>
    <td><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form>
          <%
'查询串
sql = "select id,lasttime,hits,logins,email,qq,cmp_name,cmp_url,list from cmp_user where userstatus > 4 and setinfo<>1 and "
if user_id <> "" then
	if IsNumeric(user_id) then
		sql = sql & " id="&user_id&" and "
	end if
else
	if cmp_name <> "" then
		sql = sql & " cmp_name like '%"&cmp_name&"%' and "
	end if
end if
sql = sql & " 1=1 "
if order<>"" then
	order = "desc"
end if
select case by
	case "id"
		sql = sql & " order by id " & order
	case "cmp_name"
		sql = sql & " order by cmp_name " & order
	case "hits"
		sql = sql & " order by hits " & order
	case "logins"
		sql = sql & " order by logins " & order
	case "lasttime"
		sql = sql & " order by lasttime " & order
	case "list"
		sql = sql & " order by len(list) " & order
	case else
		sql = sql & " order by id desc"
		by = "id"
		order = ""
end select
'response.Write(sql)
'分页设置
dim page,CurrentPage
page=Checkstr(Request.QueryString("page"))
CurrentPage = 1
if page <> "" then
	if IsNumeric(page) then
		if page > 0 and page < 32768 then
			CurrentPage = cint(page)
		end if
	end if
end if
dim PageC,MaxPerPage
	PageC=0
	MaxPerPage=50
set rs=Server.CreateObject("ADODB.RecordSet")
rs.Open sql,conn,1,1
IF not rs.EOF Then
	rs.PageSize=MaxPerPage
	rs.AbsolutePage=CurrentPage
	Dim rs_nums
	rs_nums=rs.RecordCount
	%>
          <tr>
            <th><a href="javascript:orderby('id');" title="点击按其排序">ID</a></th>
            <th><a href="javascript:orderby('cmp_name');" title="点击按其排序">播放器名</a></th>
            <th><a href="javascript:orderby('lasttime');" title="点击按其排序">最后更新</a></th>
            <th><a href="javascript:orderby('hits');" title="点击按其排序">查看</a></th>
			<th><a href="javascript:orderby('logins');" title="点击按其排序">登录</a></th>
            <th><a href="javascript:orderby('list');" title="点击按其排序">音乐量</a></th>
            <th align="left">CMP播放器地址</th>
            <th>QQ</th>
            <th>Email</th>
          </tr>
          <%Do Until rs.EOF OR PageC=rs.PageSize%>
          <tr align="center" onmouseover="highlight(this,'#F9F9F9');">
            <td><%=rs("id")%></td>
            <td><a href="<%=getCmpPageUrl(rs("id"))%>" target="_blank" title="<%=rs("cmp_name")%>"><%=Left(rs("cmp_name"),12)%></a></td>
            <td title="<%=rs("lasttime")%>"><%=FormatDateTime(rs("lasttime"),2)%></td>
            <td><%=rs("hits")%></td>
			<td><%=rs("logins")%></td>
            <td><%=Len(Trim(rs("list")))%></td>
            <td align="left"><a href="<%=getCmpUrl(rs("id"))%>&" target="_blank" onclick="addHits(<%=rs("id")%>);"><%=getCmpUrl(rs("id"))%></a></td>
            <td title="点击开启QQ对话"><a href="<%=getQqUrl(rs("qq"))%>" target="_blank"><%=rs("qq")%></a></td>
            <td title="点击发送邮件"><a href="mailto:<%=rs("email")%>" target="_blank"><%=rs("email")%></a></td>
          </tr>
          <%rs.MoveNext%>
          <%PageC=PageC+1%>
          <%loop%>
          <%if rs_nums>MaxPerPage then%>
          <tr>
            <td colspan="10"><div style="float:right;padding-top:5px;"><%=showpage("zh",1,"userlist.asp?cmp_name="&cmp_name&"&order="&order&"&by="&by&"",rs_nums,MaxPerPage,true,true,"个",CurrentPage)%></div></td>
          </tr>
          <%
		  end if
else
%>
          <tr>
            <td><span style="color:#FF0000;">没有找到任何相关记录</span></td>
          </tr>
          <%
end if
rs.Close
Set rs=Nothing
%>
        </form>
      </table></td>
  </tr>
</table>
<script type="text/javascript">
function searcher() {
	var str = document.getElementById("cmp_name").value;
	if(str != "<%=cmp_name%>"){
		window.location = "userlist.asp?cmp_name="+str+"&order=<%=order%>&by=<%=by%>";
	}
	return false;
}
function orderby(by) {
	var order = "<%=order%>"=="desc"?"":"desc";
	window.location = "userlist.asp?cmp_name=<%=cmp_name%>&order="+order+"&by="+by;
}
function addHits(id) {
	ajaxSend("GET","userlist.asp?action=hits&rd="+Math.round()+"&id="+id,true,null,completeHd,errorHd);
}
function completeHd(data){
	//alert(data);
}
function errorHd(errmsg){
	//alert(errmsg);
}
</script>
<%
end sub

sub hits()
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		'更新点击数
		if Session(CookieName & id)="" then
			Session(CookieName & id) = id
			conn.execute("update cmp_user set hits=hits+1 where id="&id&" ")
		end if
	end if
end if
end sub
%>
