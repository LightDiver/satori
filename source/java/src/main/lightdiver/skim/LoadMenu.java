package main.lightdiver.skim;



import main.lightdiver.skim.DAO.SystemInfoDAO;
import main.lightdiver.skim.exceptions.BaseNotConnect;

import javax.swing.tree.TreeNode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.logging.Logger;

/**
 * Created by Serj on 20.11.2015.
 */
public class LoadMenu {
    private final static Logger logger = Logger.getLogger(LoadMenu.class.getName());
    private static List<TreeNode> footerMenu1 = null;
    private static List<TreeNode> footerMenu2 = null;

    public static List<TreeNode> getFooterMenu1(){
        if (footerMenu1 == null) {
            TreeNodeMenu treeNode1 = new TreeNodeMenu("simple", "Skim Read", "#", false);

            TreeNodeMenu treeNode11 = new TreeNodeMenu("lesson", "Lessons", "#", false);
            TreeNodeMenu treeNode111 = new TreeNodeMenu("lesson", "Lessons 1", "#", true);
            TreeNodeMenu treeNode112 = new TreeNodeMenu("lesson", "Lessons 2", "#", false);
            treeNode11.addChild(treeNode111);
            treeNode11.addChild(treeNode112);

            TreeNodeMenu treeNode112p = new TreeNodeMenu("practice", "Practices", "#", false);
            TreeNodeMenu treeNode112p1 = new TreeNodeMenu("practice", "Practice 1", "#", true);
            treeNode112p.addChild(treeNode112p1);

            treeNode112.addChild(treeNode112p);

            TreeNodeMenu treeNode12 = new TreeNodeMenu("test", "Тестування", "#", true);


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
    public static HashMap<String, String> getLangs(){
        HashMap<String, String> langs;
        try {
            return SystemInfoDAO.getLangs();
        } catch (BaseNotConnect baseNotConnect) {
            logger.severe("Don't get support lang. Set UA Default");
            langs = new HashMap<>();
            langs.put("UA", "Українська");
            return langs;
        }
    }
}
