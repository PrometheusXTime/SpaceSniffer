package org.marz.spaceSniffer.v.vo {
    import flash.display.Sprite;
    import flash.events.ContextMenuEvent;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    
    import org.puremvc.as3.patterns.facade.Facade;
    
    import shinater.swing.Label;
    import org.marz.spaceSniffer.m.vo.FileTree;
    import org.marz.spaceSniffer.v.GridsMediator;

    public class GridRenderer extends Sprite {
        private static const min_size:int = 5;

        private static const LABEL_HEIGHT:Number = 20;

        private static const UNIT_ARR:Array = new Array("Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB");

        private var label:Label;

        public function GridRenderer() {
            super();
            label = new Label('path 0');

            this.doubleClickEnabled = true;

//			addEventListener(MouseEvent.CLICK, onClick);
            addEventListener(MouseEvent.DOUBLE_CLICK, onClick);
//            addEventListener(MouseEvent.RIGHT_CLICK, onClick);

            var menu:ContextMenu = new ContextMenu;
            this.contextMenu = menu;

            var item:ContextMenuItem;
            item = new ContextMenuItem('parent');
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelected);
            menu.items.push(item);
            item = new ContextMenuItem('open');
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelected);
            menu.items.push(item);
            item = new ContextMenuItem('delete');
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelected);
            menu.items.push(item);
        }

        protected function onMenuItemSelected(event:ContextMenuEvent):void {
            switch (event.target.caption) {
                case 'parent':
                    if (fileTree.parent) {
                        Facade.getInstance().sendNotification(GridsMediator.SHOW, fileTree.parent);
                    }
                    break;
                case 'open':
					try{
                    	fileTree.file.openWithDefaultApplication();
					}catch(e:Error){
						trace(e);
					}
                    break;
                case 'delete':
                    if (fileTree.file.isDirectory)
                        fileTree.file.deleteDirectory(true);
                    else
                        fileTree.file.deleteFile();
                    break;
            }
        }

        protected function onClick(event:MouseEvent):void {
            switch (event.type) {
                case MouseEvent.CLICK:
                    break;
                case MouseEvent.DOUBLE_CLICK:
                    Facade.getInstance().sendNotification(GridsMediator.SHOW, fileTree);
                    break;
                case MouseEvent.RIGHT_CLICK:
                    break;
            }
            event.stopImmediatePropagation();
        }

        public function update(fileTree:FileTree, rect:Rectangle):void {
            this.fileTree = fileTree;

            if (depth > 2)
                return;

//            if (rect.width < min_size || rect.height < min_size)
//                return;

            graphics.clear();
            graphics.lineStyle(1);
            if (fileTree.file.isDirectory)
                graphics.beginFill(0x008888, .8);
            else
                graphics.beginFill(0xffffff, .8);

            graphics.drawRect(0, 0, rect.width, rect.height);
            graphics.endFill();

			var name:String = fileTree.file.nativePath;
			name = name.substr(name.lastIndexOf('/') + 1);
			name = name.substr(name.lastIndexOf('\\') + 1);
            label.setAutoSize('left');

            var size:Number = fileTree.size;
            var _index:int;
            var sizeStr:String = (size / Math.pow(1024, (_index = int(Math.log(size) / Math.log(1024))))).toPrecision(3) + UNIT_ARR[_index];
            if (fileTree.file.isDirectory)
                label.setText(name + ': ' + sizeStr);
            else
                label.setText(name + '\n' + sizeStr);

            if (rect.width < label.width)
                label.setText(sizeStr + '');

            if (rect.width >= label.width && rect.height >= label.height) {
                addChild(label);

                if (false == fileTree.file.isDirectory) {
                    label.x = (width - label.width) >> 1;
                    label.y = (height - label.height) >> 1;
                }
            }

            horizal = rect.width > rect.height;

            if (fileTree.file.isDirectory) {
                var list:Array = fileTree.getDirectoryListing();

                var clientW:Number = rect.width - min_size * 2;
                var clientH:Number = rect.height - LABEL_HEIGHT - min_size;

                var area:int = clientW * clientH;

                var acturalW:Number = clientW;
                var acturalH:Number = clientH;
                var cursorX:int = min_size;
                var cursorY:int = LABEL_HEIGHT;

                if (clientW < 1 || clientH < 1)
                    return;

                fileTree.group(this, new Rectangle(cursorX, cursorY, acturalW, acturalH), fileTree.getDirectoryListing().concat(), size);
                return;

                for each (var i:FileTree in list) {
                    var renderer:GridRenderer = new GridRenderer;
                    renderer.depth = depth + 1;

                    horizal = acturalW > acturalH;

                    if (horizal) {
                        renderer.x = cursorX;
                        renderer.y = cursorY;

                        var h:Number = acturalH;
                        var w:int = area * (i.size / size) / h;
                        renderer.update(i, new Rectangle(0, 0, Math.max(1, w), Math.max(1, h)));

                        cursorX += w;
                        acturalW -= w;
                    } else {
                        renderer.x = cursorX;
                        renderer.y = cursorY;

                        w = acturalW;
                        h = area * (i.size / size) / w;

                        renderer.update(i, new Rectangle(0, 0, Math.max(1, w), Math.max(1, h)));

                        cursorY += h;
                        acturalH -= h;
                    }
                    addChild(renderer);
                }
            }
        }

        private var _depth:int;

        public function get depth():int {
            return _depth;
        }

        public function set depth(value:int):void {
            if (_depth == value)
                return;
            _depth = value;
        }

        public var horizal:Boolean;

        public var fileTree:FileTree;
    }
}
