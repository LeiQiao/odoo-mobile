
function getElementsByXPath(xpath)
{
    var result = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
    if( result != null )
    {
        var nodes = [];
        var node=result.iterateNext();
        while( node != null )
        {
            nodes.push(node);
            node = result.iterateNext();
        }
    }
    return nodes;
}

function replaceConditionKeyword(conditions)
{
    conditions = conditions.replace(/ and /i, " && ");
    conditions = conditions.replace(/ or /i, " || ");
    return conditions;
}

function calcDocumentHeight()
{
    var bodyBottomMargin = parseInt((window.getComputedStyle ? getComputedStyle(document.body, null) : document.body.currentStyle)['marginBottom']);
    
    var imageMaxHeight = 0;
    var nodes = getElementsByXPath("//*[@class='o_kanban_image']");
    for( i in nodes )
    {
        var imageNode = nodes[i];
        if( imageMaxHeight < (imageNode.offsetTop + imageNode.scrollHeight + bodyBottomMargin) )
        {
            imageMaxHeight = (imageNode.offsetTop + imageNode.scrollHeight + bodyBottomMargin);
        }
    }
    
    var detailMaxHeight = 0;
    nodes = getElementsByXPath("//*[@class='oe_kanban_details']");
    for( i in nodes )
    {
        var detailNode = nodes[i];
        if( detailMaxHeight < (detailNode.offsetTop + detailNode.scrollHeight) )
        {
            detailMaxHeight = (detailNode.offsetTop + detailNode.scrollHeight);
        }
    }
    
    var documentHeight = document.height;
    if( imageMaxHeight > documentHeight )
    {
        documentHeight = imageMaxHeight;
    }
    if( detailMaxHeight > documentHeight )
    {
        documentHeight = detailMaxHeight;
    }
    if( (imageMaxHeight == 0) && (detailMaxHeight == 0) )
    {
        documentHeight += bodyBottomMargin;
    }
    
//    nslog("documentHeight"+documentHeight+
//          " imageMaxHeight: "+imageMaxHeight+
//          " detailMaxHeight: "+detailMaxHeight+
//          " bodyBottomMargin:"+bodyBottomMargin+"");
    
    onUpdateHeight(documentHeight);
}

function formatCurrency(num)
{
    num = num.toString().replace(/\$|\,/g,'');
    if(isNaN(num))
        num = "0";
    sign = (num == (num = Math.abs(num)));
    num = Math.floor(num*100+0.50000000001);
    cents = num % 100;
    num = Math.floor(num/100).toString();
    if( cents < 10 )
    {
        cents = "0" + cents;
    }
    for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)
    {
        num = num.substring(0,num.length-(4*i+3))+','+num.substring(num.length-(4*i+3));
    }
    return (((sign)?'':'-') + num + '.' + cents);
}

function addValueNode(node, value)
{
    var element = document.createElement("value");
    var valueNode = document.createTextNode(value);
    element.appendChild(valueNode);
    
    node.insertBefore(element, node.childNodes[0]);
}

function removeValueNode(node)
{
    try{
    for( var i=node.childNodes.length-1; i>=0; i-- )
    {
        var childNode = node.childNodes[i];
        if( childNode.nodeName == "VALUE" )
        {
            node.removeChild(childNode);
        }
        else
        {
            removeValueNode(childNode);
        }
    }
}catch(e){nslog(e);}
}

var record;

function setRecordValue(recordJson)
{
    record = JSON.parse(recordJson);
    
    var nodes = getElementsByXPath("//*[@t-if]");
    for( i in nodes )
    {
        var node = nodes[i];
        try {
            var visible = eval(replaceConditionKeyword(node.attributes["t-if"].value));
            if( !visible )
            {
                node.parentNode.removeChild(node);
            }
        } catch(e) {nslog("Error" + e);}
    }
    
    nodes = getElementsByXPath("//field");
    for( i in nodes )
    {
        var node = nodes[i];
        var fieldName = node.attributes["name"].value;
        var fieldValue = eval("record."+fieldName+".value");
        if( (node.attributes["widget"] != null) &&
           (node.attributes["widget"].value == "monetary") )
        {
            fieldValue = formatCurrency(fieldValue);
            if( record.currency_id.value == "USD" )
            {
                fieldValue = "$ " + fieldValue;
            }
            if( record.currency_id.value == "CNY" )
            {
                fieldValue = fieldValue + " ¥";
            }
        }
        removeValueNode(node);
        addValueNode(node, fieldValue);
    }
    
    nodes = getElementsByXPath("//img[@t-att-src]");
    for( i in nodes )
    {
        var node = nodes[i];
        try {
            node.src = eval(node.attributes["t-att-src"].value);
        } catch(e) {nslog("Error" + e);}
    }
    
    nodes = getElementsByXPath("//*[@t-esc]");
    for( i in nodes )
    {
        var node = nodes[i];
        var fieldValue = eval(replaceConditionKeyword(node.attributes["t-esc"].value));
        
        removeValueNode(node);
        addValueNode(node, fieldValue);
    }
    
    nodes = getElementsByXPath("//*[@t-attf-class]");
    for( i in nodes )
    {
        var node = nodes[i];
        var classNames = node.attributes["t-attf-class"].value;
        var exps = classNames.match(/#{[^}]*(?=})/);
        evaledClassNames = classNames.replace(/#{[^}]*}/, "");
        if( (exps != null) && (exps.length > 0) )
        {
            for( var i=0; i<exps.length; i++ )
            {
                var exp = exps[i].substr(2);
                evaledClassNames += " " + eval(exp);
            }
        }
        node.className = evaledClassNames;
    }
    
    return document.height;
}

function kanban_image(model, field, id)
{
    if( eval("record."+field) == null )
    {
        // 如果小图没有换大图
        if( field == "image_small" )
        {
            return kanban_image(model, "image", id);
        }
        // 如果大图没有换小图
        if( field == "image" )
        {
            return kanban_image(model, "image_small", id);
        }
        return "";
    }
    
    var imageData = eval("record."+field+".raw_value");
    if( imageData.length == 0 )
    {
        return "";
    }
    return "data:image/png;base64,"+imageData;
}









