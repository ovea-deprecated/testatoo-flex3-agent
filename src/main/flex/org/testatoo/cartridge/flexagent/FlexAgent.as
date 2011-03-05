/**
 * Copyright (C) 2008 Ovea <dev@testatoo.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.testatoo.cartridge.flexagent {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;

import mx.containers.FormItem;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.DataGrid;
import mx.controls.Label;
import mx.controls.LinkButton;
import mx.controls.RadioButton;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.controls.Button;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.UIComponent;

import flash.utils.describeType;

import mx.managers.PopUpManager;
import mx.managers.SystemManager;

public class FlexAgent extends UIComponent {

    private var rootApplication:UIComponent;
    private var debugOutput:TextArea;

    public function FlexAgent(root:UIComponent) {

        super();
        rootApplication = root;

        if (ExternalInterface.available) {
            ExternalInterface.addCallback("existComponent", existComponent);
            ExternalInterface.addCallback("componentType", componentType);
            ExternalInterface.addCallback("flexComponentType", flexComponentType);
            ExternalInterface.addCallback("buttonText", buttonText);
            ExternalInterface.addCallback("buttonIcon", buttonIcon);
            ExternalInterface.addCallback("isComponentEnabled", isComponentEnabled);
            ExternalInterface.addCallback("isComponentVisible", isComponentVisible);
            ExternalInterface.addCallback("dropDownSelectedValue", dropDownSelectedValue);
            ExternalInterface.addCallback("dropDownLabelField", dropDownLabelField);
            ExternalInterface.addCallback("dropDownValues", dropDownValues);
            ExternalInterface.addCallback("dropDownSelectValue", dropDownSelectValue);
            ExternalInterface.addCallback("label", label);
            ExternalInterface.addCallback("typeOnTextInput", typeOnTextInput);
            ExternalInterface.addCallback("textInputValue", textInputValue);
            ExternalInterface.addCallback("textInputMaxLength", textInputMaxLength);
            ExternalInterface.addCallback("clickOn", clickOn);
            ExternalInterface.addCallback("panelTitle", panelTitle);
            ExternalInterface.addCallback("existAlertBox", existAlertBox);
            ExternalInterface.addCallback("alertBoxTitle", alertBoxTitle);
            ExternalInterface.addCallback("alertBoxMessage", alertBoxMessage);
            ExternalInterface.addCallback("closeAlertBox", closeAlertBox);
            ExternalInterface.addCallback("dataGridColumnNumber", dataGridColumnNumber);
            ExternalInterface.addCallback("dataGridColumnTitle", dataGridColumnTitle);
            ExternalInterface.addCallback("dataGridColumnField", dataGridColumnField);
            ExternalInterface.addCallback("dataGridRowNumber", dataGridRowNumber);
            ExternalInterface.addCallback("dataGridCellNumForRow", dataGridCellNumForRow);
            ExternalInterface.addCallback("dataGridCellValue", dataGridCellValue);
            ExternalInterface.addCallback("dataGridColumnDataField", dataGridColumnDataField);
            ExternalInterface.addCallback("dataGridColumnDataField", dataGridColumnDataField);
            ExternalInterface.addCallback("isChecked", isChecked);
            ExternalInterface.addCallback("contain", contain);

            ExternalInterface.addCallback("ready", ready);
        }
    }

    public function setOutputDebugElement(textArea:TextArea):void {
        debugOutput = textArea;
        debugOutput.text = "Start Debuging \n";
    }

    private function existComponent(id:String):Boolean {
        return Boolean(findComponentById(id, rootApplication));
    }

    /**
     * Recursive function to navigate the object tree and locate the element
     * @param  id  id of component
     * @param  container  reference to the parent object
     * @return  reference to object if found, otherwise null
     */
    private function findComponentById(id:String, container:UIComponent):UIComponent {
        for (var currentChildIndex:int = 0; currentChildIndex < container.numChildren; currentChildIndex++) {
            var child:DisplayObject = container.getChildAt(currentChildIndex);

            if (!(child is UIComponent))
                continue;

            if ((container.getChildAt(currentChildIndex) as UIComponent).id == id)
                return container.getChildAt(currentChildIndex) as UIComponent;

            var uiObject:UIComponent = findComponentById(id, container.getChildAt(currentChildIndex) as UIComponent);
            if (uiObject)
                return uiObject;
        }

        return null;
    }

    private function componentType(id:String):String {
        var component:UIComponent = findComponentById(id, rootApplication);
        // Test before Button because CheckBox and RadioButton extend Button
        if (component is LinkButton) return "Link";
        if (component is CheckBox) return "CheckBox";
        if (component is RadioButton) return "Radio";
        if (component is Button) return "Button";
        if (component is TextInput) {
            if ((component as TextInput).displayAsPassword)
                return "PasswordField";
            else
                return "TextField";
        }
        if (component is ComboBox) return "DropDown";
        if (component is DataGrid) return "DataGrid";
        if (component is Panel) return "Panel";

        return "Undefined";
    }

    private function flexComponentType(id:String):String {
        var classInfo:XML = describeType(findComponentById(id, rootApplication));
        var className:String = classInfo.@name.toString();

        if (className == 'mx.controls::Button') return "Button";
        if (className == 'mx.controls::CheckBox') return "CheckBox";
        if (className == 'mx.controls::RadioButton') return "RadioButton";
        if (className == 'mx.controls::ComboBox') return "DropDown";
        if (className == 'mx.controls::TextInput') return "TextInput"; 
        if (className == 'mx.controls::LinkButton') return "LinkButton";
        if (className == 'mx.controls::DataGrid') return "DataGrid";
        if (className == 'mx.containers::Panel') return "Panel";

        return "Undefined";
    }

    private function buttonText(id:String):String {
        var button:Button = findComponentById(id, rootApplication) as Button;
        return button.label;
    }

    private function buttonIcon(id:String):String {
        var button:Button = findComponentById(id, rootApplication) as Button;
        return button.getStyle("icon");
    }

    private function isComponentEnabled(id:String):Boolean {
        return findComponentById(id, rootApplication).enabled;
    }

    private function isComponentVisible(id:String):Boolean {
        return findComponentById(id, rootApplication).visible;
    }

    private function dropDownSelectedValue(id:String):String {
        var dropDown:ComboBox = findComponentById(id, rootApplication) as ComboBox;
        var field:String = dropDown.labelField;
        return dropDown.selectedItem[field];
    }

    private function dropDownLabelField(id:String):String {
        return (findComponentById(id, rootApplication) as ComboBox).labelField;
    }

    private function dropDownValues(id:String, field:String):String {
        var dropDown:ComboBox = findComponentById(id, rootApplication) as ComboBox;
        var values:String = "";
        var firstPass:Boolean = true;
        for (var rowIndex:int = 0; rowIndex < dropDown.dataProvider.length; rowIndex++) {
            if (firstPass)
                values = values + dropDown.dataProvider[rowIndex][field];
            else
                values = values + "," + dropDown.dataProvider[rowIndex][field];
            firstPass = false;
        }
        return values;
    }

    private function dropDownSelectValue(id:String, value:String):void {
        var dropDown:ComboBox = findComponentById(id, rootApplication) as ComboBox;
        var field:String = dropDown.labelField;
        for (var index:int = 0; index < dropDown.dataProvider.length; index++) {
            if (value == dropDown.dataProvider[index][field]) {
                dropDown.selectedIndex = index;
                break;
            }
        }
    }

    private function typeOnTextInput(id:String, value:String):void {
        (findComponentById(id, rootApplication) as TextInput).text = value;
    }

    private function textInputValue(id:String):String {
        return (findComponentById(id, rootApplication) as TextInput).text;
    }

    private function textInputMaxLength(id:String):int {
        return (findComponentById(id, rootApplication) as TextInput).maxChars;
    }

    private function label(id:String):String {
        var component:UIComponent = findComponentById(id, rootApplication);

        if (component is Button)
            return (component as Button).label;

        var parent:DisplayObjectContainer = component.parent;
        var lastLabel:Label;

        if (parent is FormItem)
            return (parent as FormItem).label;

        // Also try this way ;)
        for (var index:int = 0; index < parent.numChildren; index++) {
            if (parent.getChildAt(index) is UIComponent) {
                var child:UIComponent = parent.getChildAt(index) as UIComponent;
                if (describeType(child).@name.toString() == "mx.controls::Label")
                    lastLabel = parent.getChildAt(index) as Label;

                if (child.id == id) {

                    if (lastLabel.text == null || lastLabel.text == "")
                        return lastLabel.htmlText;
                    return lastLabel.text;
                }
            }
        }
        
        return "";
    }

    private function panelTitle(id:String):String {
        return (findComponentById(id, rootApplication) as Panel).title;
    }

    private function existAlertBox():Boolean {
        return getAlert() != null;
    }

    private function alertBoxTitle(id:String):String {
        return getAlert().title;
    }

    private function alertBoxMessage():String {
        return getAlert().text;
    }

    private function closeAlertBox():void {
        PopUpManager.removePopUp(getAlert());
    }

    private function isChecked(id:String):Boolean {
        var component:UIComponent = findComponentById(id, rootApplication);
        if (component is RadioButton) {
            return (component as RadioButton).selected;
        }
        if (component is CheckBox) {
            return (component as CheckBox).selected;
        }
        return false;
    }

    private function dataGridColumnNumber(id:String):int {
        return (findComponentById(id, rootApplication) as DataGrid).columns.length;
    }

    private function dataGridCellNumForRow(id:String, rowNum:int):int {
        return (findComponentById(id, rootApplication) as DataGrid).dataProvider[rowNum].length;
    }

    private function dataGridRowNumber(id:String):int {
        return (findComponentById(id, rootApplication) as DataGrid).dataProvider.length;
    }

    private function dataGridColumnTitle(id:String, columnIndex:int):String {
        return (((findComponentById(id, rootApplication) as DataGrid).columns[columnIndex]) as DataGridColumn).headerText;
    }

    private function dataGridColumnField(id:String, columnIndex:int):String {
        return (((findComponentById(id, rootApplication) as DataGrid).columns[columnIndex]) as DataGridColumn).dataField;
    }

    private function dataGridCellValue(id:String, rowNum:int, field:String):String {
        var columns:Array = (findComponentById(id, rootApplication) as DataGrid).columns;
        var functionLabel:Function;
        var column:DataGridColumn;

        for (var index:int = 0; index < columns.length; index++)
            if (columns[index].dataField == field) {
                functionLabel = columns[index].labelFunction;
                column = columns[index];
            }

        if (functionLabel != null)
            return functionLabel((findComponentById(id, rootApplication) as DataGrid).dataProvider[rowNum], column).toString();

        return (findComponentById(id, rootApplication) as DataGrid).dataProvider[rowNum][field].toString();
    }

    private function dataGridColumnDataField(id:String, index:int):String {
        return (findComponentById(id, rootApplication) as DataGrid).columns[index].dataField;
    }

    private function clickOn(id:String):void {
        findComponentById(id, rootApplication).dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false));
    }

    private function contain(containerId:String, componentId:String):Boolean {
        var container:UIComponent = findComponentById(containerId, rootApplication);
        return findComponentById(componentId, container) != null;
    }

    // -----------------------------------------------------------------------------------------------------
    // -----------------------------------------------------------------------------------------------------
    // -----------------------------------------------------------------------------------------------------
    private function getAlert():Alert {
        try {
            var sm:SystemManager = SystemManager.getSWFRoot(rootApplication) as SystemManager;
            for (var i:int = 0; i < sm.numChildren; i++) {
                var child:Object = sm.getChildAt(i);
                var classInfo:XML = describeType(child);
                if (classInfo.@name.toString() == 'mx.controls::Alert') return Alert(child);
            }
        }
        catch(e:Error) {
        }
        return null;
    }

    private function ready():Boolean {
        return true;
    }


}
}