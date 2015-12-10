package main.lightdiver.skim.model.adminka;

import main.lightdiver.skim.entity.UsersAction;
import org.richfaces.model.Filter;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.Serializable;

/**
 * Created by Serj on 10.12.2015.
 */
@ManagedBean
@ViewScoped
public class AdminStatisticFilterBean implements Serializable{
    private String userTerminalClientFilter;

    public Filter<?> getUserTerminalClientFilterImpl(){
        return new Filter<UsersAction>(){

            public boolean accept(UsersAction usersAction) {
                String userTerminal = getUserTerminalClientFilter();
                if (userTerminal == null || userTerminal.length() == 0 ||
                        usersAction.getUserTerminalClient().toLowerCase().contains(userTerminal.toLowerCase()))
                    //userTerminal.equals(usersAction.getUserTerminalClient()))
                {
                    return true;
                }
                return false;
            }
        };
    }

    public String getUserTerminalClientFilter() {
        return userTerminalClientFilter;
    }

    public void setUserTerminalClientFilter(String userTerminalClientFilter) {
        this.userTerminalClientFilter = userTerminalClientFilter;
    }
}
