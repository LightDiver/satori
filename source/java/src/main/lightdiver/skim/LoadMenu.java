package main.lightdiver.skim;



import javax.swing.tree.TreeNode;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Serj on 20.11.2015.
 */
public class LoadMenu {
    private static List<TreeNode> footerMenu1 = null;
    private static List<TreeNode> footerMenu2 = null;

    public static List<TreeNode> getFooterMenu1(){
        if (footerMenu1 == null) {
            TreeNodeMenu treeNode1 = new TreeNodeMenu("simple", "Skim Read", "#", false);

            TreeNodeMenu treeNode11 = new TreeNodeMenu("lesson", "Lessons", "#", false);
            TreeNodeMenu treeNode111 = new TreeNodeMenu("lesson", "Lessons 1", "#", true);
            TreeNodeMenu treeNode112 = new TreeNodeMenu("lesson", "Lessons 2", "#", true);
            treeNode11.addChild(treeNode111);
            treeNode11.addChild(treeNode112);

            TreeNodeMenu treeNode12 = new TreeNodeMenu("practice", "Practices", "#", false);
            TreeNodeMenu treeNode121 = new TreeNodeMenu("practice", "Practice 1", "#", true);
            treeNode12.addChild(treeNode121);

            treeNode1.addChild(treeNode11);
            treeNode1.addChild(treeNode12);

            TreeNodeMenu treeNode2 = new TreeNodeMenu("simple", "Article", "#", true);

            footerMenu1 = new ArrayList<>();
            footerMenu1.add(treeNode1);
            footerMenu1.add(treeNode2);
        }
        return footerMenu1;
    }
    public static List<TreeNode> getFooterMenu2(){
        if (footerMenu2 == null) {

            TreeNodeMenu treeNode1 = new TreeNodeMenu("simple", "About", "about.xhtml", true);
            TreeNodeMenu treeNode2 = new TreeNodeMenu("simple", "Contacts", "#", true);
            TreeNodeMenu treeNode3 = new TreeNodeMenu("simple", "Registration", "register.xhtml", true);
            TreeNodeMenu treeNode4 = new TreeNodeMenu("simple", "Literature", "#", true);

            footerMenu2 = new ArrayList<>();
            footerMenu2.add(treeNode1);
            footerMenu2.add(treeNode2);
            footerMenu2.add(treeNode3);
            footerMenu2.add(treeNode4);
        }
        return footerMenu2;
    }
}
